Rails.application.routes.draw do


  post '/verify', to:'users#verify'
  post '/forgot_password', to: 'passwords#forgot'
  post '/reset', to: 'passwords#reset'
  get "/show_notifications", to:'notifications#show'
  post "/create_friend", to:'friendships#create'
  post "/accept/:to_accept", to:'friendships#accept'
  post '/decline/:to_decline', to:'friendships#decline'
  get 'friendlist', to: 'friendships#friends'
  # post '/forgot-password', to: 'users#forgot_password'
  # get 'friendships/update'
  ## shows all the posts of all the users
  get '/post_index/:page', to:'posts#index'

  ## creates a post 
  post '/create', to:'posts#create'
  
  ## shows all the posts of a particular user
  get '/show_post', to:'posts#show'
  
  ## likes a post
  post '/like_post/:post_id', to:'posts#like_post'

  ## likes a specific comment of a specific post
  post '/like_comment/:post_id/:comment_id', to:'posts#like_comment'

  ## shows the count and users who likes a specific post 
  get '/show_likes_post/:post_id', to:'posts#showlikesonpost'

  ## shows the count and users who likes a specific comment on a specific post
  get '/show_likes_comment/:post_id/:comment_id', to:'posts#showlikesoncomment'

  ## comments on a specific post
  post '/comment/:post_id', to:'posts#comment'

  get '/index', to:'users#index'
  post '/signup', to:'users#signup'
  post '/login', to:'users#login'
  delete '/logout', to:'users#logout'
  patch '/update', to:'users#update'
  get '/show', to:'users#show'
  delete '/delete', to:'users#delete'



end
