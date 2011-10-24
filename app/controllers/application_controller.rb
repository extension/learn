# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_learner
  
  def current_learner
    nil
  end
  
end
