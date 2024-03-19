
class UsersController < ApplicationController
  skip_before_action :authenticate_user, only:[:login, :signup, :index, :verify, :refresh]
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
      render json: {error: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def verify
    @token = params[:token]
  
    begin
      @decoded = JsonWebToken.decode(@token)
    rescue JWT::DecodeError => e
      render json: { message: 'Invalid token' }, status: :unprocessable_entity
      return
    end
    begin
      @user = User.find(@decoded["user_id"])
    rescue ActiveRecord::RecordNotFound => e
      render json: {message: "Entity not found"}
      return
    end
    @user.update(verification: 'true')
    render json: { message: "Account verified successfully", user: @user }
  end
  

  def login
    @user = User.find_by_email(params[:email])
    if @user.verification == 'false'
      render json: {message: 'Account not verified, please check your email for the verfication'}, status: :unprocessable_entity
    elsif @user && @user.authenticate(params[:password])
      access_token = JsonWebToken.encode(user_id: @user.id)
      refresh_token = JsonWebToken.encode(user_id: @user.id, exp: 6.months.from_now)
      render json: {name: @user.name, access_token: access_token, refresh_token: refresh_token, message: "user logged in successfully"}, status: :ok
    else 
      render json: {message:"Wrong password, or user does not exist",error: @user.errors.full_messages}, status: :unprocessable_entity 
    end
  end

def refresh 
  @token = params[:refresh_token]
  begin
    @decoded_token = JsonWebToken.decode(@token)
  rescue JWT::DecodeError => e
    puts e
    render json: { message: 'Invalid refresh token or the refresh token is expired' }, status: :unprocessable_entity
    return
  end
    x = @decoded_token["user_id"]
    @user = User.find(x)
    @access_token = JsonWebToken.encode(user_id: @user.id)
    @user.update(token: @access_token)
    render json: {message: "New access token generated"}, status: :ok 
end

  def logout
    render json:{message:"The user is successfully logged out"}
  end

  def update
    @user = @current_user 

    if @user.update(user_params)
      # byebug
      if params[:profile_picture].present?
        @user.profile_picture = Cloudinary::Uploader.upload(params[:profile_picture])['secure_url']
      end
  
      if params[:cover_picture].present?
        @user.cover_picture = Cloudinary::Uploader.upload(params[:cover_picture])['secure_url']
      end
      @user.save
      render json: {message:"User updates successfully", user: @user}, status: :ok
    else
      render json: { message:"User does not exist", errors: @user.errors.full_messages }, status: :unauthorized
    end
  end

  def show
    @user = @current_user 
    render json: {user: @user}, status: :ok
  end


  def delete 
    @user = @current_user 
    @user.destroy
    render json: {message: "User is deleted"}
  end

private 
  def user_params 
    params.permit(:name, :email, :password, :password_confirmation, :phone, :profile_picture, :cover_picture)
  end
end
