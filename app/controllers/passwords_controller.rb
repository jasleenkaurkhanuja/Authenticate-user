class PasswordsController < ApplicationController
  skip_before_action :authenticate_user
  def forgot
    if params[:email].blank? 
      render json: {error: 'Email not present'}
    end
    @user = User.find_by(email: params[:email])
    if @user 
      otp = generate_otp 
      @user.update(otp: otp)
      ForgotPasswordMailer.with(user: @user, otp: otp).otp_email.deliver_now
      render json: {otp: otp, message: "email sent successfully"}
    end
  end

  def reset
    @user = User.find_by(email: params[:user][:email])
    @otp = params[:user][:otp]
    byebug
    if @user && @user.otp == @otp
      @user.update(password_params)
      render json:{message: "password updated successfully"}
    else 
      render json: {message: "wrong otp or the user does not exists"}
    end
  end

  private
  def generate_otp 
    SecureRandom.random_number(100000..999999)
  end

  def password_params 
    params.require(:user).permit(:password, :password_confirmation)
  end
end
