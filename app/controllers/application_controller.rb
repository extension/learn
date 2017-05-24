# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  include AuthLib
  helper_method :current_learner

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'yes','YES','y','Y']
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE','no','NO','n','N']

  protect_from_forgery
  before_filter :touch_sign_in_settings, :store_location, :set_time_zone_from_user, :set_last_active_at_for_learner

  def touch_sign_in_settings
    #TODO use devise settings and update those columns
    true
  end

  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
    payload[:auth_id] = current_learner.id if current_learner
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

  def do_410
    render :template => "/shared/410", :status => 410
  end

  def set_time_zone_from_user
    if(current_learner)
      timezone = Time.zone = current_learner.time_zone
    elsif(cookies[:user_selected_timezone])
      timezone = Time.find_zone(cookies[:user_selected_timezone])
    elsif(cookies[:system_timezone])
      timezone = Time.find_zone(cookies[:system_timezone])
    else
      timezone = Time.zone = Settings.default_display_timezone
    end
    Time.zone = timezone
    true
  end


  def set_last_active_at_for_learner
    if current_learner
      if current_learner.last_active_at != Date.today
        current_learner.update_attribute(:last_active_at, Date.today)
      end
    end
    return true
  end

end
