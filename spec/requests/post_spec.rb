require 'rails_helper'

def json 
    # puts response.body
    JSON.parse(response.body)
end

RSpec.describe "Post", type: :request do 
    describe 'Show all the posts visible to the current user' do 
        # get '/post_index/:page', to:'posts#index'
        let(:user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: user.id)}
        let(:blocked_user) {FactoryBot.create(:user, verification: "true")}
        let(:friend) {FactoryBot.create(:user, verification: "true")}
        let(:post_everyone) {FactoryBot.create(:post, user:user, permission:"everyone")}
        let(:post_my_friends) {FactoryBot.create(:post, user:friend, permission:"my_friends")}
        let(:post_only_me) {FactoryBot.create(:post, user:friend, permission:"only_me")}
        let!(:block_user) {Block.create(blocked: blocked_user, blocker:user)}
        let!(:friendship) {Friendship.create( sender_id:user.id, reciever_id:friend.id, status:"accepted")}
        let!(:shared_post) {Share.create(original_id: user.id, user_id: user.id, status: 'active', post_id: post_everyone.id)}

        it 'return a list of all the posts visible to the current user' do 
            get "/post_index/#{1}", headers: {'Authorization'=>"Bearer #{access_token}"}
            expect(response).to have_http_status(:ok)
            expect(json['message']).to eq('All posts')
            expect(json['posts'].count).to eq(6)
            expect(json['people_user_is_following']).to include(friend.id)
            expect(json['shared']).to include(hash_including('id' => post_everyone.id))
        end
    end
    
    describe "Create post" do 
        let(:user) {FactoryBot.create(:user)}
        let(:access_token) {JsonWebToken.encode(user_id: user.id)}
        let(:my_post) {FactoryBot.create(:post, permission: "everyone", user_id: user.id)}
        # post '/create', to:'posts#create'
        it 'creates a new post with valid parameters' do 
            post '/create', params:{
                post:
                {
                    title: my_post.title,
                    content: my_post.content,
                    permission: my_post.permission
                }
            }, headers: {'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Post saved successfully")
            expect(response).to have_http_status(:created)
        end

        it 'returns an error as there should be no empty value present' do 
            post '/create', params:{
                post:
                {
                    title: '',
                    content: '',
                    permission: my_post.permission
                }
            }, headers: {'Authorization'=>"Bearer #{access_token}"}
            expect(json['message']).to eq("Post not saved")
            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe 'Show all the posts of the current user' do 
        let(:my_user) { FactoryBot.create(:user, verification: "true") }
        let(:access_token) { JsonWebToken.encode(user_id: my_user.id) }
        

        # get '/show_post', to:'posts#show'
        it 'fetches all the posts of a particular user' do 
            posts = FactoryBot.create_list(:post, 10, user_id:my_user.id)
            get '/show_post', headers:{'Authorization'=>"Bearer #{access_token}"}
            # byebug
            expect(json['posts'].count).to eq(10)
            expect(json['user']['email']).to eq(my_user.email)
        end
    end

    describe 'show likes on a particular post' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}
        let(:my_post) {FactoryBot.create(:post, user_id: my_user.id)}
        let (:another_user) {FactoryBot.create(:user, verification: "true")}
        let!(:like1) { my_post.likes.create(user_id: my_user.id) }
        let!(:like2) { my_post.likes.create(user_id: another_user.id) }

        it 'show total likes' do 
            # like1.save 
            # like2.save
            # get '/show_likes_post/:post_id', to:'posts#showlikesonpost'
            get "/show_likes_post/#{my_post.id}", headers: {'Authorization'=>"Bearer #{access_token}"}
            expect(json['total_likes']).to eq(2)
            expect(json['liked_by'].map {|like| like['user_id'] }).to include(my_user.id, another_user.id)
            expect(response).to have_http_status(:ok)
        end
    end

    describe 'show likes on a particular comment of a particular post' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}
        let(:my_post) {FactoryBot.create(:post, user_id: my_user.id)}
        let(:comment) {my_post.comments.create(user_id: my_user.id, description: "nice post")}
        let (:another_user) {FactoryBot.create(:user, verification: "true")}
        let!(:like1) { comment.likes.create(user_id: my_user.id) }
        let!(:like2) { comment.likes.create(user_id: another_user.id) }
        #   get '/show_likes_comment/:post_id/:comment_id', to:'posts#showlikesoncomment'

        it 'shows likes on the particular comment' do 
            get "/show_likes_comment/#{my_post.id}/#{comment.id}", headers: {'Authorization'=>"Bearer #{access_token}"}
            expect(json['total_likes']).to eq(2)
            expect(json['liked_by'].map {|like| like['user_id'] }).to include(my_user.id, another_user.id)
            expect(response).to have_http_status(:ok)
        end
    end

    describe 'show comments on the particular post' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}
        let(:my_post) {FactoryBot.create(:post, user_id: my_user.id)}
        let!(:comment1) {my_post.comments.create(user_id: my_user.id, description: "nice post")}
        let(:another_user) {FactoryBot.create(:user, verification: "true")}
        let!(:comment2) { my_post.comments.create(user_id: another_user.id, description: "wow_nice post") }   

        it 'show all comments on the post with comment counts' do 
            get "/show_comments/#{my_post.id}", headers: {'Authorization' => "Bearer #{access_token}"}
            expect(json['total_comments']).to eq(2)
            expect(json['comments'].map {|comment| comment['description'] }).to include("wow_nice post", "nice post")
            expect(response).to have_http_status(:ok)
        end
    end

    describe 'like_comment' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}
        let(:my_post) {FactoryBot.create(:post, user_id: my_user.id)}
        let!(:comment1) {my_post.comments.create(user_id: my_user.id, description: "nice post")}
        
        
        it 'likes the comment if it is not already liked by the current user' do 
            post "/like_comment/#{my_post.id}/#{comment1.id}", headers: {'Authorization' => "Bearer #{access_token}"}
            expect(json['message']).to eq("Like added to the comment")
            expect(response).to have_http_status(:ok)
        end

        it 'unlikes the comment if it is already liked by the current user' do 
            like1 = comment1.likes.create(user_id: my_user.id)
            post "/like_comment/#{my_post.id}/#{comment1.id}", headers: {'Authorization' => "Bearer #{access_token}"}
            expect(json['message']).to eq("Like deleted from the comment")
            expect(response).to have_http_status(:ok)
        end
    end

    describe 'like_post' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}
        let(:my_post) {FactoryBot.create(:post, user_id: my_user.id)}
        let(:another_user) {FactoryBot.create(:user, verification: "true")}
        let!(:like1) {my_post.likes.create(user_id: another_user.id)}

        # post '/like_post/:post_id', to:'posts#like_post'

        it 'likes the post which was previously not liked' do
            post "/like_post/#{my_post.id}", headers: {'Authorization' => "Bearer #{access_token}"}
            expect(json['message']).to eq('Like saved')
            expect(response).to have_http_status(:ok)
            expect(json['total_likes']).to eq(2)
        end

        it 'unlikes the already liked post' do 
            like1 = my_post.likes.create(user_id: my_user.id)
            post "/like_post/#{my_post.id}", headers: {'Authorization' => "Bearer #{access_token}"}
            expect(json['message']).to eq('Like deleted')
            expect(response).to have_http_status(:ok)
            expect(json['total_likes']).to eq(1)
        end
    end

    describe 'do_comment' do 
        let(:my_user) {FactoryBot.create(:user, verification: "true")}
        let(:access_token) {JsonWebToken.encode(user_id: my_user.id)}
        let(:my_post) {FactoryBot.create(:post, user_id: my_user.id)}

        #  post '/comment/:post_id', to:'posts#comment'

        it 'comments on the given post by the current user' do 
            post "/comment/#{my_post.id}", params:{ comment:{description: "nice post, good job"} }, headers: {'Authorization' => "Bearer #{access_token}"}
            expect(json['message']).to eq("Comment added successfully")
            expect(response).to have_http_status(:created)
            expect(json['description']).to eq("nice post, good job")
        end
    end
end
# def comment
#     @user = @current_user 
#     @post = Post.find(params[:post_id])
#     @comment = @post.comments.create(comment_params)
#     @comment.user_id = @user.id 

#     if @comment.save
#       render json: {message: "Comment added successfully", description: @comment.description, id: @comment.id}
#     else 
#       render json: {message: "Comment not added", error: @comment.errors.full_messages}
#     end
#   end
