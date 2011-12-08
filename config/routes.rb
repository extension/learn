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
  
  match "settings/profile" => "settings#profile", :via => :get
  match "settings/notifications" => "settings#notifications", :via => :get
  
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
  
  match "mailer/:action" => 'mailer'
  root :to => 'home#index'

end
