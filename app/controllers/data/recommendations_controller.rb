# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Data::RecommendationsController < ApplicationController
  before_filter :authenticate_learner!
  before_filter :require_admin
  
  def index
    @recommendation_count = Recommendation.group("day").count
    @mailer_count = Recommendation.includes(:mailer_cache).where('mailer_caches.open_count > 0').group("day").count
    @recommended_event_counts = RecommendedEvent.includes([:event,{:recommendation => :learner}]).group("recommendations.day").count
    @recommended_event_viewed_counts = RecommendedEvent.includes([:event,{:recommendation => :learner}]).where(viewed: true).group("recommendations.day").count
    
    @connected_event_counts = {}
    RecommendedEvent.includes([:event,{:recommendation => :learner}]).each do |re|
      learner = re.recommendation.learner
      if(learner.events.include?(re.event))
        if(@connected_event_counts[re.recommendation.day])
          @connected_event_counts[re.recommendation.day] += 1
        else
          @connected_event_counts[re.recommendation.day] = 1
        end
      end
    end
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
  
  def show
    @recommendation = Recommendation.find_by_id(params[:id])
  end
  
  def recent
    @recommended_event_list = RecommendedEvent.includes([:event,{:recommendation => :learner}]).order('recommended_events.created_at DESC').paginate(page: params[:page])
  end
  
end
