# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

Learn::Application.routes.draw do
  devise_for :learners, :path => '/', :controllers => { :sessions => "learners/sessions", :registrations => "learners/registrations" }
  devise_for :authmaps, :controllers => { :omniauth_callbacks => "authmaps/omniauth_callbacks" } do 
    get '/authmaps/auth/:provider' => 'authmaps/omniauth_callbacks#passthru'
  end
  
  resources :comments, :only => [:create, :update, :destroy, :show]
  resources :ratings, :only => [:create]  
  resources :learners do
    member do
      get 'portfolio'
      get 'learning_history'
    end
  end
  
  resources :events do
    member do
      post 'addanswer'
      post 'makeconnection'
    end
    
    collection do
      get 'learner_token_search'
    end
  end
  # recommended event tracking
  match "/recommended_event/:id" => "events#recommended", :as => 'recommended_event'  
  

  # webmail routes - prefer using the named routes instead of 
  # catchalls, but that may get tiring after a while, we'll see
  match "webmail/recommendation/:hashvalue" => "webmail#recommendation", :as => 'webmail_recommendation'
  match "webmail/examples/recommendation"    => "webmail#example_recommendation"
  
  
  root :to => 'home#index'

end
