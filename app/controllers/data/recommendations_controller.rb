# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Data::RecommendationsController < ApplicationController
  before_filter :authenticate_learner!
  before_filter :require_admin
  
  def index
  end
  
  def projected
    event_options = {}
    event_options[:min_score] = params[:min_score] ? params[:min_score].to_i : Settings.minimum_recommendation_score
    event_options[:remove_connectors] = params[:remove_connectors] ? Preference::TRUE_PARAMETER_VALUES.include?(params[:remove_connectors]) : true
    @event_list = Event.projected_epoch.potential_learners(event_options) 
  end
    
  def event
    @event = Event.find_by_id(params[:event_id])
    @event_options = {}
    @event_options[:min_score] = 1
    @event_options[:remove_connectors] = false
  end
  
end
