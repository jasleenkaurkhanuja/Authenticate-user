class NotificationsController < ApplicationController
  def show
    @user = @current_user 
    @notifications = Notification.where(reciever_id: @user.id)
    # @notifications = Notification.all

    render json: {notifications: @notifications}
  end
end
