Rails.application.routes.draw do


  ##---------------------------------User Controller------------------------------##

  # get all the users
  get '/index', to:'users#index'

  # signup the user
  post '/signup', to:'users#signup'

  # login the user
  post '/login', to:'users#login'

  # logout the user
  delete '/logout', to:'users#logout'

  # update the user
  patch '/update', to:'users#update'

  # show the details current user
  get '/show', to:'users#show'

  # delete the current user
  delete '/delete', to:'users#delete'

  # Refresh the access token when expired
  post '/refresh', to: 'users#refresh'

  # Verifies the new user
  post '/verify', to:'users#verify'

  ##-------------------------------Post Conttroller------------------------------------##

  # shows all the posts of all the users
  get '/post_index/:page', to:'posts#index'

  # creates a post 
  post '/create', to:'posts#create'
  
  # shows all the posts of a particular user
  get '/show_post', to:'posts#show'
  
  # likes a post
  post '/like_post/:post_id', to:'posts#like_post'

  # likes a specific comment of a specific post
  post '/like_comment/:post_id/:comment_id', to:'posts#like_comment'

  # shows the count and users who likes a specific post 
  get '/show_likes_post/:post_id', to:'posts#showlikesonpost'

  # shows comments on a particular post
  get '/show_comments/:post_id', to: 'posts#showcomments'

  # shows the count and users who likes a specific comment on a specific post
  get '/show_likes_comment/:post_id/:comment_id', to:'posts#showlikesoncomment'

  # comments on a specific post
  post '/comment/:post_id', to:'posts#comment'


  ##------------------------------Password Controller----------------------------##

  # forgot password
  post '/forgot_password', to: 'passwords#forgot'

  # resets the password
  post '/reset', to: 'passwords#reset'

  ##-----------------------------Friendship Controller--------------------------##

  # creates friendship
  post "/create_friend", to:'friendships#create'

  # accepts the friendship request
  post "/accept/:to_accept", to:'friendships#accept'

  # declines the friendship request
  post '/decline/:to_decline', to:'friendships#decline'

  # shows the friendlist of the particular user
  get '/friendlist', to: 'friendships#friends'

  ##-------------------------------Notification Controller-----------------------##

  # shows all the nofication of the current user
  get "/show_notifications", to:'notifications#show'

  ##-------------------------------Block Controller-------------------------------##

  # shows all the blocked users that the current user has blocked
  get '/blocks', to: 'blocks#index'

  # blocks the user
  post '/block/:to_be_blocked', to: 'blocks#block'

  # unblocks the user
  post '/unblock/:id', to: 'blocks#unblock'

  ##---------------------------------Share Controller--------------------------##
  
  # shares a post
  post '/share/:post_id', to:'shares#create'

  # deletes the shared post
  get 'shares/delete'

  # get 'shares/index'
end
