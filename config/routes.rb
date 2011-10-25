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
  
  resources :events
  root :to => 'home#index'
end
