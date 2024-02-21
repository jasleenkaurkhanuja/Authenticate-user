class UsersController < ApplicationController
  skip_before_action :authenticate_user, only:[:login, :signup, :index]
  def index
    @users = User.all
    render json: @users
  end

  def signup
    @user = User.create(user_params)
    if @user.save 
      render json: {name: @user.name, email: @user.email}, status: :created 
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by_email(params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render json: {name: @user.name, token:token}
    else 
      render json: {error: @user.errors.full_messages}, status: :unprocessable_entity 
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
