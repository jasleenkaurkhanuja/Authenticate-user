Rails.application.routes.draw do
  get '/index', to:'users#index'
  post '/signup', to:'users#signup'
  post '/login', to:'users#login'
  delete '/logout', to:'users#logout'
  patch '/update', to:'users#update'
  get '/show', to:'users#show'
  delete '/delete', to:'users#delete'
end
