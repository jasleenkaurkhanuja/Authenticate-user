class UsersController < ApplicationController
  skip_before_action :authenticate_user, only:[:login, :signup, :index, :verify]
  def index
    @users = User.all
    render json: @users
  end

  def signup
    @user = User.create(user_params)

    token = JsonWebToken.encode(user_id: @user.id)
    verification_url = "http://localhost:3000/verify?token=#{token}"
    if @user.save 
      
      UserMailer.with(user: @user, verification_url: verification_url).account_verification.deliver_now
      render json: {name: @user.name, email: @user.email}, status: :created 
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def verify
    @token = params[:token]
    @decoded = JsonWebToken.decode(@token)
    byebug
    if @decoded.present? && @decoded.key?("user_id")
      @user = User.find(@decoded["user_id"])
      if @user
        @user.update(verification: 'true')
        render json: {message: "Account verified successfully"}
      else 
        render json: {message: "Account not verified", error: @user.errors.full_messages}
      end
    else 
      render json: {message: "decoded not present"}
    end

  end

  def login
    @user = User.find_by_email(params[:user][:email])
    if @user.verification == 'false'
      render json: {message: 'Account not verified, please check your email for the verfication'}
    elsif @user && @user.authenticate(params[:user][:password])
      access_token = JsonWebToken.encode(user_id: @user.id)
      refresh_token = JsonWebToken.encode(user_id: @user.id, exp: 6.months.from_now)
      render json: {name: @user.name, access_token:token, refresh_token}
    else 
      render json: {error: @user.errors.full_messages}, status: :unprocessable_entity 
    end
end

def refresh 
  @decoded_token = JsonWebToken.decode(params[:refresh_token])
  if @decode_token && @decoded_token["user_id"]
    @user = User.find(@decode_token["user_id"])
    if @decode_token["exp"] >= Time.now.to_i 
      @access_token = JsonWebToken.encode(user_id: @user.id)
      render json: {message: "refresh token generated"}, status: :ok 
    else 
      render json: {message: "refresh_token expired"}, status: :unprocessable_entity
    end
  else 
    render json: {message: "Invalid refresh token"}, status: :unprocessable_entity
  end
end

  def logout
    render json:{message:"The user is successfully logged out"}
  end

  def update
    @user = @current_user 
    if @user.update(user_params)
      render json:{user:@user, message:"User updated Successfully"}
    else 
      render json:{error:@user.errors.full_messages}, status: :unprocessable_entity
    end

  end

  def show
    @user = @current_user 
    render json: {user: @user}
  end


  def delete 
    @user = @current_user 
    if @user.destroy
      render json: {message: "User is deleted"}
    else 
      render json: {meesage: "User not deleted"}
    end
  end

private 
  def user_params 
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone)
  end
end
