class Authmaps::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @learner = Authmap.find_for_twitter_oauth(env["omniauth.auth"], current_learner)
    if @learner.persisted?
      if @learner.retired == false
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      else
        redirect_to retired_url
      end
      
      sign_in_and_redirect @learner, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to new_learner_session_url
    end
  end
  
  def facebook
    @learner = Authmap.find_for_facebook_oauth(env["omniauth.auth"], current_learner)
    if @learner.persisted?
      if @learner.retired == false
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      else
        redirect_to retired_url
      end
      sign_in_and_redirect @learner, :event => :authentication
    else
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_learner_session_url
    end
  end
  
  def people
    @learner = Authmap.find_for_people_openid(env["omniauth.auth"], current_learner)
    if @learner.persisted?
      if @learner.retired == false
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "eXtension"
      else
        redirect_to retired_url
        return
      end
      sign_in_and_redirect @learner, :event => :authentication
    else
      session["devise.people_data"] = env["omniauth.auth"]
      redirect_to new_learner_session_url
    end
  end
  
  def google
    @learner = Authmap.find_for_google_oauth(env["omniauth.auth"], current_learner)
    if @learner.persisted?
      if @learner.retired == false
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      else
        redirect_to retired_url
      end
      sign_in_and_redirect @learner, :event => :authentication
    else
      session["devise.google_data"] = env["omniauth.auth"]
      redirect_to new_learner_session_url
    end
  end
  
  def failure
    flash[:notice] = "Access denied. Please try again."
    redirect_to new_learner_session_url
    return
  end
  
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end