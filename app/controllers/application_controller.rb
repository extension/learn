# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_time_zone_from_learner
  
  
  def fake_learner
    if(params[:fake_another_learner])
      sign_out()
    end
    
    if(!current_learner)
      if(params[:fake_learner] and learner = Learner.find_by_id(params[:fake_learner]))
        sign_in(learner)
      end
    end
  end
  
  def set_time_zone_from_learner
    if(current_learner)
      Time.zone = current_learner.time_zone
    end
    true
  end
  
end
