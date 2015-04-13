# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'yes','YES','y','Y']
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE','no','NO','n','N']

  protect_from_forgery
  before_filter :store_location
  around_filter :set_timezone

  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
    payload[:auth_id] = current_learner.id if current_learner
  end

  def store_location
    session[:learner_return_to] = request.url unless (params[:controller] == "authmaps/omniauth_callbacks" || params[:controller] == "learners/sessions")
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

  private

  def set_timezone
    if(current_learner)
      timezone = Time.zone = current_learner.time_zone
    elsif(cookies[:user_selected_timezone])
      timezone = Time.find_zone(cookies[:user_selected_timezone])
    else
      timezone = Time.find_zone(cookies[:timezone])
    end
    Time.use_zone(timezone) { yield }
  end
end
