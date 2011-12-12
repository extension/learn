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
      get 'upcoming'
      get 'tags'
      get 'recent'
      get 'search'
    end
  end
  # individual tag match
  match "/events/tag/:tags" => "events#tags", :as => 'event_tag'  
  
  # recommended event tracking
  match "/recommended_event/:id" => "events#recommended", :as => 'recommended_event'  
  
  namespace :feeds do
    resources :events, :only => [:index, :show], :defaults => { :format => 'xml' }
  end

  # webmail routes - prefer using the named routes instead of 
  # catchalls, but that may get tiring after a while, we'll see
  match "webmail/:mailer_cache_id/logo" => "webmail#logo", :as => 'webmail_logo'
  match "webmail/recommendation/:hashvalue" => "webmail#recommendation", :as => 'webmail_recommendation'
  match "webmail/examples/recommendation"    => "webmail#example_recommendation"
  match "webmail/examples/reminder"    => "webmail#example_reminder"
  match "webmail/examples/recording"    => "webmail#example_recording"
  match "webmail/examples/activity"    => "webmail#example_activity"
  match "webmail/view/:hashvalue" => "webmail#view", :as => 'webmail_view'
  
  
  root :to => 'home#index'

end
