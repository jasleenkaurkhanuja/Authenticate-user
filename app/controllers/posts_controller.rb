class PostsController < ApplicationController
  def index 
    @user = @current_user
    @posts = []
    @blocked = Block.where(blocked_id: @user.id).pluck(:blocker_id) + Block.where(blocker_id: @user.id).pluck(:blocked_id)

    @people_user_is_following =  @user.sent_friendships.where(status: 'accepted').pluck(:reciever_id)

    @posts += Post.where(permission: 'everyone').where.not(user_id: @blocked).or(Post.where(user_id: @people_user_is_following, permission:'my_friends')).or(Post.where(user_id: @user.id)).order(created_at: :desc).page(params[:page])
  
    @shared_id = Share.where(user_id: @user.id, status: 'active').where.not(user_id: @blocked).pluck(:post_id)
    @shared = Post.where(id: @shared_id) 
    @posts += @shared 
    
    
    render json: { posts: @posts, people_user_is_following: @people_user_is_following, shared: @shared }
  end
  

  def create
    @user = @current_user
    @post = @user.posts.create(post_params)
    if @post.save
      render json: {Message: "Post saved successfully", post:@post}, status: :created 
    else 
      render json: {Message: "Post not saved", error: @post.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    @user = @current_user 
    @posts = @user.posts.all 
    render json:{user: @user.name, posts: @posts}
  end

  def showlikesonpost
    @user = @current_user
    @post = Post.find(params[:post_id])
    likes_count = @post.likes.count 
    @likes = @post.likes.all
    render json:{total_likes: likes_count, liked_by: @likes}
  end

  def showlikesoncomment
    @user = @current_user
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:comment_id])
    likes_count = @comment.likes.count 
    @likes = @comment.likes.all
    render json:{total_likes: likes_count, liked_by: @likes}
  end

  def showcomments
  end

  def like_comment 
    @user = @current_user
    @post = Post.find(params[:post_id])
    # byebug
    @comment = @post.comments.find(params[:comment_id])
    @like = @comment.likes.find_or_initialize_by(user_id: @user.id)
    # byebug
    if @like.persisted?
      @like.destroy
      render json:{message: "Like deleted from the comment"}
    else 
      @like.save
      render json:{message: "Like added to the comment"}
    end
  end

  def like_post
    @user = @current_user 
    @likeable = Post.find(params[:post_id])
    @like = @likeable.likes.find_or_initialize_by(user_id: @user.id)
    # byebug
    if @like.persisted?
      @like.destroy 
      render json:{message: "Like deleted"}
    else 
      @like.save 
      render json:{message: "Like saved"}
    end
  end

  def comment
    @user = @current_user 
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(comment_params)
    @comment.user_id = @user.id 

    if @comment.save
      render json: {message: "Comment added successfully", description: @comment.description, id: @comment.id}
    else 
      render json: {message: "Comment not added", error: @comment.errors.full_messages}
    end
  end

private 
  def post_params 
    params.require(:post).permit(:title, :content, :permission)
  end
  def comment_params 
    params.require(:comment).permit(:description)
  end
end


