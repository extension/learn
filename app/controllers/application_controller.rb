# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_time_zone_from_learner
  before_filter :store_location
  
  def store_location
    session[:learner_return_to] = request.url unless (params[:controller] == "authmaps/omniauth_callbacks" || params[:controller] == "learners/sessions")
  end

  def set_time_zone_from_learner
    if(current_learner)
      Time.zone = current_learner.time_zone
    else
      Time.zone = Settings.default_display_timezone
    end
    true
  end
  
  # devise hook for the url to redirect to after a learner has authenticated
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end
  
  def stored_location_for(resource)
    if current_learner && !params[:redirect_to].blank?
      return params[:redirect_to]
    end
    return nil
  end
    
  def require_admin
    if(!(current_learner && current_learner.is_admin?))
      return redirect_to(root_url)
    end
  end
  
  # used by paper_trail for tracking whodunit 
  def user_for_paper_trail
    current_learner
  end
  
  # used by paper_trail for tracking additional information
  def info_for_paper_trail
    { :ipaddress => request.remote_ip }
  end
  
  def record_not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
end
