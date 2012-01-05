# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_activity_log_ip
  before_filter :set_time_zone_from_learner

  def set_time_zone_from_learner
    if(current_learner)
      Time.zone = current_learner.time_zone
    else
      Time.zone = Learn::Application.config.time_zone
    end
    true
  end
  
  # devise hook for the url to redirect to after a learner has authenticated
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end
  
  def stored_location_for(resource)
    if current_learner && params[:redirect_to]
      return params[:redirect_to]
    end
    return nil
  end
  
  def set_activity_log_ip
    if(!request.env["REMOTE_ADDR"].blank?)
      ActivityLog.request_ipaddr = request.env["REMOTE_ADDR"]
    end
  end
  
  def require_admin
    if(!(current_learner && current_learner.is_admin?))
      return redirect_to(root_url)
    end
  end
  
  
end
