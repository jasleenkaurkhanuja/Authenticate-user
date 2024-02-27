class FriendshipsController < ApplicationController
  def create
    @user = @current_user 
    @friend = User.find(params[:id])
    # byebug
    @check = Friendship.find_by(sender_id: @current_user.id, reciever_id: @friend.id)
    byebug
    # @friendship = Friendship.create(sender_id: @current_user.id, reciever_id: @friend.id, status:'pending')
    # Check if the friendship already exists
    if @check
      if @check.status == 'accepted'
        render json: {message: "Already friends"}
      elsif @check.status == 'pending'
        render json: {message: "Friend request already in queue"}
      else 
        render json: {message: "Some error occured"}
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
    # @friendships = Friendship.all
    @friendships = Friendship.where(status: 'accepted', reciever_id: @user.id)
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
    @friendship = Friendship.find_by(sender_id: @sender.id)
    @notifications = Notification.find_by(reciever_id: @user.id)
    @notification.destroy
    if @friendship.destroy
      render json: {message: "Friend request declined"}
    else 
      render json: {message: "Friend request not declined"}
    end
  end

  def update
  end
end
