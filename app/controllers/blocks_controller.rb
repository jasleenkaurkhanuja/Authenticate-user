class BlocksController < ApplicationController
  def index
    begin
      @blocks = Block.all
      byebug
      render json: { message: "Blocked people", blocked_people: @blocks }
    rescue StandardError => e
      render json: { message: "Error occurred", error: e.message }, status: :unprocessable_entity
    end
  end

  def block
    @blocker = @current_user 
    @blocked = User.find(params[:to_be_blocked])
    @b = Block.find_by(blocker_id: @blocker.id, blocked_id: @blocked.id) 
    byebug
    if @b
      render json: {message: "User already blocked"}, status: :ok
    else 
      @block = Block.create(blocker_id: @blocker.id, blocked_id: @blocked.id)
      byebug
      if @block.save
        @friends1 = Friendship.find_by(sender_id: @blocker.id, reciever_id: @blocked.id)
        @friends2 = Friendship.find_by(sender_id: @blocked.id, reciever_id: @blocker.id)

        if @friends1
          @friends1.destroy
        end 
        if @friends2
          @friends2.destroy
        end
        render json: {message: "User blocked successfully"}, status: :unprocessable_entity
      else 
        render json: {message: "Some error occurred", error: @block.errors.full_messages}
      end
    end
  end

  def unblock
    @user = @current_user 
    @unblocked = User.find(params[:id])

    @block = Block.find_by(blocker_id: @user, blocked_id: @unblocked) 
    byebug
    if @block 
      @block.destroy 
      render json: {message: "User unblocked successfully", user: @user, unblocked: @unblocked} 
    else 
      render json: {message: "some error occurred", error: @block.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
