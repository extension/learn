# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class LearnersController < ApplicationController
  before_filter :authenticate_learner!, only: [:portfolio, :learning_history]
  
  def index
  end
  
  def portfolio
    @learner = Learner.find_by_id(params[:id])
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
  
    @attended_events = @learner.events.attended.order("event_connections.created_at DESC").limit(5)
    @watched_events = @learner.events.watched.order("event_connections.created_at DESC").limit(5)
    @presented_events = @learner.presented_events.order("session_start DESC").limit(5)
    @bookmarked_events = @learner.events.bookmarked.order("event_connections.created_at DESC").limit(15)
  end
  
  def learning_history
    @learner = current_learner
    params[:type].present? ? @type = params[:type].capitalize : @type = 'All'
    
    @list_title = "Learning History(#{@type})"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    
    case params[:type]
    when 'presented'
      @events = @learner.presented_events
    when 'attended'
      @events = @learner.events.attended
    when 'watched'
      @events = @learner.events.watched
    when 'bookmarked'
      @events = @learner.events.bookmarked
    when 'commented'
      @events = @learner.commented_events
    when 'rated'
      @events = @learner.rated_items.events
    when 'answered_questions'
      @events = @learner.events_answered
    when nil
      event_id_array = []
      @presented_events = @learner.presented_events.map{|e| e.id}
      event_id_array.concat(@presented_events)
      @attended_events = @learner.events.attended.map{|e| e.id}
      event_id_array.concat(@attended_events)
      @watched_events = @learner.events.watched.map{|e| e.id}
      event_id_array.concat(@watched_events)
      @bookmarked_events = @learner.events.bookmarked.map{|e| e.id}
      event_id_array.concat(@bookmarked_events)
      @commented_events = @learner.commented_events.map{|e| e.id}
      event_id_array.concat(@commented_events)
      @rated_events = @learner.rated_items.event_ratings.map{|e| e.rateable_id}
      event_id_array.concat(@rated_events)
      @answered_events = @learner.events_answered.map{|e| e.id}
      event_id_array.concat(@answered_events)
      @events = Event.where("id IN (#{event_id_array.join(',')})").paginate(:page => params[:page]).order('session_start DESC')
    else
      return redirect_to(root_url, :error => 'Invalid learning history specified.')
    end
  end
end
