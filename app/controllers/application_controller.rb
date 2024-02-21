# require 'bcrypt'
class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token
    # before_action :set_current_user
    before_action :authenticate_user

    def authenticate_user
        token = request.headers['Authorization']&.split(' ')[1]
        decoded_token = JsonWebToken.decode(token)

        if decoded_token 
            @current_user = User.find_by(id: decoded_token["user_id"])
            # byebug
            # render json: {user: @current_user, token:token}
        else 
            render json: {error: "Unauthorized user"}, status: :unprocessable_entity
        end
    end

end
