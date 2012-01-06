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
  resources :ratings, :only => [:create, :destroy]  
  resources :learners do
    member do
      get 'portfolio'
    end
  end
  
  match "learning_history" => "learners#learning_history", :via => :get
  match "presented_history" => "learners#presented_history", :via => :get
  match "attended_history" => "learners#attended_history", :via => :get
  match "watched_history" => "learners#watched_history", :via => :get
  match "bookmarked_history" => "learners#bookmarked_history", :via => :get
  match "commented_history" => "learners#commented_history", :via => :get
  match "rated_history" => "learners#rated_history", :via => :get
  match "answered_question_history" => "learners#answered_question_history", :via => :get
    
  match "settings/profile" => "settings#profile", :via => [:get, :put]
  match "settings/notifications" => "settings#notifications", :via => [:get, :post]
  
  resources :events do
    member do
      post 'addanswer'
      post 'makeconnection'
      post 'notificationexception'
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

  # webmail routes 
  scope "webmail" do
    match "/:mailer_cache_id/logo" => "webmail#logo", :as => 'webmail_logo'
    match "/recommendation/:hashvalue" => "webmail#recommendation", :as => 'webmail_recommendation'
    match "/view/:hashvalue" => "webmail#view", :as => 'webmail_view'
  end

  # webmail example routing
  namespace "webmail" do
    namespace "examples" do
      match "/:action"
    end
  end
  
  namespace "data" do
    resources "recommendations", :only => [:index] do
      collection do
        get 'projected'
        get 'event'
      end
    end
  end
  
      
  root :to => 'home#index'

end
