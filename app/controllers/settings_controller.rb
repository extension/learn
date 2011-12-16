# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class SettingsController < ApplicationController
  before_filter :authenticate_learner!
  
  def profile
    @learner = current_learner
    if request.put?      
      if @learner.update_attributes(params[:learner])
        redirect_to(settings_profile_path, :notice => 'Event was successfully updated.')
      else
        render :action => 'profile'
      end
    end
  end
  
  def notifications
  end
  
  def portfolio
  end
end
