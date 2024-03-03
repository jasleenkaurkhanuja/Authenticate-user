class FriendshipsController < ApplicationController
  def create
    @user = @current_user 
    @friend = User.find(params[:id])
    # byebug
    @check = Friendship.find_by(sender_id: @current_user.id, reciever_id: @friend.id)
    # byebug
    # @friendship = Friendship.create(sender_id: @current_user.id, reciever_id: @friend.id, status:'pending')
    # Check if the friendship already exists
    if @check
      if @check.status == 'accepted'
        render json: {message: "Already friends"}
      elsif @check.status == 'pending'
        render json: {message: "Friend request already in queue"}
      elsif @check.status == 'declined' && @check.created_at > 30.days.ago
        render json: {message: 'Friend request not sent(cool off period)'}
      elsif @check.status == 'declined' && @check.created_at <= 30.days.ago
        @check.destroy 
        @friendship = Friendship.create(sender_id: @current_user.id, reciever_id: @friend.id, status: "pending")
        @notification = Notification.create(sender_id: @current_user.id, reciever_id: @friend.id)
        if @friendship.save 
          if @notification.save 
            render json: {message: "Friend request sent"}
          else 
            render json: {message: "An error occured"}
          end
        else 
          render json: {message: "Friend request not sent"}
        end
      end
    else
      @friendship = Friendship.create(sender_id: @current_user.id, reciever_id: @friend.id, status:'pending')
      @notification = Notification.create(sender_id: @current_user.id, reciever_id: @friend.id)
      if @friendship.save 
        if @notification.save 
          render json: {note: "Notification sent", sender: @user.name, reciever: @friend.name, message: "Friend request send"}
        else 
          render json: {sender: @user.name, reciever: @friend.name, message: "Friend request not send", error: @friendship.errors.full_messages}
        end
      end
    end
  end

  def friends 
    @user = @current_user
    @friendships = Friendship.all
    # @friendships = Friendship.where(status: 'accepted', reciever_id: @user.id)
    render json: {Friends: @friendships}
  end

  def accept
    @user = @current_user 
    @sender = User.find(params[:to_accept])
    @friendship = Friendship.find_by(sender_id: @sender.id, reciever_id: @user.id)
    @friendship.status = "accepted"
    @notification = Notification.find_by(reciever_id: @user.id)
    
    if @friendship.update(status: 'accepted')
      @notification.destroy
      render json: {message: "Friend request accepted"}
    else 
      render json: {message: "Friend request not accepted"}
    end
  end


  def decline
    @user = @current_user 
    @sender = User.find(params[:to_decline])
    @friendship = Friendship.find_by(sender_id: @sender.id, reciever_id: @user.id)
    if @friendship.update(status: 'declined')
      @notification = Notification.find_by(reciever_id: @user.id)
      if @notification.destroy
        render json: {message: "Friend request declined, notification deleted.", friendship: @friendship}
      else 
        render json: {message: "Notofication not deleted"}
      end
    else
      render json: {message: 'Friendship not declined.'}
    end
  end

  def update
  end
end
