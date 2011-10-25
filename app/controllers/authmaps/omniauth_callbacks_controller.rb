class Authmaps::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @learner = Authmap.find_for_twitter_oauth(env["omniauth.auth"], current_learner)
    if @learner.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @learner, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to new_learner_registration_url
    end
  end
  
  def failure
    flash[:notice] = "Twitter access denied. Please try again."
    redirect_to new_learner_registration_url
    return
  end
  
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end