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
  
  resources :events do
    member do
      post 'addanswer'
      post 'makeconnection'
    end
    
    collection do
      get 'learner_token_search'
    end
  end
  
  root :to => 'home#index'
  

  match "mailer/:action" => 'mailer'
end
