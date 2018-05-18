# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

Learn::Application.routes.draw do
  # auth
  match '/logout', to:'auth#end', :as => 'logout'
  match '/auth/:provider/callback', to: 'auth#success'
  match '/auth/failure', to: 'auth#failure'

  resources :learners do
    member do
      get 'portfolio'
      get 'presented_history'
      get 'attended_history'
      get 'created_history'
      get 'viewed_history'
      get 'followed_history'
      post 'block'
      post 'unblock'
    end

    collection do
      get 'token_search'
    end
  end

  match "ajax/:action", to: "ajax", :via => [:get, :post]
  match "learning_history" => "learners#learning_history", :via => :get
  match "register_learner" => "learners#register_learner", :via => :post
  match "settings/profile" => "settings#profile", :via => [:get, :put]
  match "settings/notifications" => "settings#notifications", :via => [:get, :post]
  match "settings/learning_profile" => "settings#learning_profile", :via => [:get, :post, :put]
  match "settings/privacy" => "settings#privacy", :via => [:get, :post]
  match "contact_us" => "home#contact_us", :via => :get
  match "retired" => "home#retired", :via => :get
  match "hosting" => "home#hosting", :via => :get
  match "signin" => "home#signin", :via => :get
  match "search/all" => "search#all", :via => [:get]
  match "search/learners" => "search#learners", :via => [:get]
  match "search/events" => "search#events", :via => [:get]
  match "learn_registrants" => "events#export_registrants", :via => :get

  # individual tag match
  match "/events/tag/:tags" => "events#tags", :as => 'events_tag'

  resources :events do
    member do
      post 'makeconnection'
      post 'notificationexception'
      get 'backstage'
      get 'webinarinfo'
      get 'history'
      get 'diff_with_previous'
      post 'restore'
      delete 'destroy_registrants'
      get 'delete_event'
      post 'delete_event'
    end

    collection do
      get 'learner_token_search'
      get 'upcoming'
      get 'tags'
      get 'recent'
      get 'canceled'
      get 'deleted'
      get 'broadcast'
    end
  end

  resources :material_links, :only => [:create, :destroy, :edit, :update] do
    collection do
      get 'cancel_edit'
    end
  end

  # recommended event tracking
  match "/recommended_event/:id" => "events#recommended", :as => 'recommended_event'

  # widgets for upcoming events
  match "widgets/front_porch" => "widgets#deprecated", :via => [:get]
  match "widgets/upcoming" => "widgets#deprecated", :via => [:get]
  match "widgets/events" => "widgets#events", :via => [:get, :post]
  match "widgets/" => "widgets#index", :via => [:get]
  match "widgets/generate_widget_snippet" => "widgets#generate_widget_snippet", :via => [:post]

  namespace :feeds do
    resources :events, :only => [:index], :defaults => { :format => 'xml' } do
      collection do
        get 'upcoming', :defaults => { :format => 'xml' }
        get 'tags', :defaults => { :format => 'xml' }
      end
    end
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

  # data routes
  scope "data" do
    match "/" => "data#overview", :as => 'data_overview'
    match "/recommendations" => "data#recommendations", :as => 'data_recommendations'
    match "/activity" => "data#activity", :as => 'data_activity'
    match "/events" => "data#events", :as => 'data_events'
    match "/zoom_webinars" => "data#zoom_webinars", :as => 'data_zoom_webinars'
    match "/presenters" => "data#presenters", :as => 'data_presenters'
    match "/recommended_event/:event_id" => "data#recommended_event", :as => 'data_recommended_event'
    match "/projected_recommendations" => "data#projected_recommendations", :as => 'data_projected_recommendations'
    match "/recent_recommendations" => "data#recent_recommendations", :as => 'data_recent_recommendations'
    match "/blocked_activity" => "data#blocked_activity", :as => 'data_blocked_activity'
    match "/tags" => "data#tags", :as => 'tag_token_search'
  end

  root :to => 'home#index'

end
