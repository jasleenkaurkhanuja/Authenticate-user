class SharesController < ApplicationController
  def index
    @shares = Share.all 
    render json: {message: "All posts", shares: @shares}
  end

  def create
    @user = @current_user 
    @post = Post.find(params[:post_id])
    @original = User.find(@post.user_id)
    
    # @b1 = Block.find_by(blocker_id: @user.id, blocked_id: @original.id)
    # @b2 = Block.find_by(blocker_id: @original_id, blocked_id: @user.id)

    @friends = Friendship.where(sender_id: @user.id, reciever_id: @original_id, status: 'accepted')
    if @post.permission != 'everyone' || !@friends
      render json: {message: "Post could not be shared", permision: @post.permission, friends: @friends}
    else 
      if Share.find_by(original_id: @original.id, user_id: @user.id, post_id: @post.id)
        render json: {message: "Post shared already"}
      else
        @share = Share.create(original_id: @original.id, user_id: @user.id, status: 'active', post_id: @post.id)
        if @share.save 
          render json: {message: "The post is shared successfully", share_post: @post}, status: :created 
        else 
          render json: {message: "The post in not shared, some error occurred", error: @share.errors.full_messages}
        end
      end
    end
  end

  def delete
  end
end
