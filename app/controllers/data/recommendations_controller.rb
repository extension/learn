# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Data::RecommendationsController < ApplicationController
  before_filter :authenticate_learner!
  before_filter :require_admin
  
  def index
    event_options = {}
    event_options[:min_score] = params[:min_score] ? params[:min_score].to_i : 3
    event_options[:remove_connectors] = params[:remove_connectors] ? Preference::TRUE_PARAMETER_VALUES.include?(params[:remove_connectors]) : true
    @current_recommendation_events = Learner.recommended_events(event_options)    
  end
  
end
