# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class LearnersController < ApplicationController
  before_filter :authenticate_learner!, except: [:index]
  
  def index
  end
  
  def portfolio
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :portfolio_setting)
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
    prepare_history('Activity')
    # don't think there's a better AR way of doing this, it's pretty fast as is 
    @activities = @learner.activity_logs.select("activity_logs.created_at AS created_at, ea.*, e.title AS title, e.id AS event_id").joins("JOIN event_activities AS ea on ea.id = activity_logs.loggable_id JOIN events as e on e.id = ea.event_id").where("activity_logs.loggable_type = 'EventActivity' AND ea.activity IN (#{EventActivity::HISTORY_ITEMS.join(',')})").paginate(:page => params[:page]).order("activity_logs.created_at DESC")
  end
  
  def presented_history
    prepare_history('Presented')
    @events = @learner.presented_events.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def attended_history
    prepare_history('Attended')
    @events = @learner.events.attended.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def watched_history
    prepare_history('Watched')
    @events = @learner.events.watched.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def bookmarked_history
    prepare_history('Bookmarked')
    @events = @learner.events.bookmarked.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def commented_history
    prepare_history('Commented')
    @events = @learner.commented_events.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def rated_history
    prepare_history('Rated')
    @events = @learner.rated_events.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def answered_question_history
    prepare_history('Answered Questions')
    @events = @learner.events_answered.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  private
  
  def prepare_history(history_type)
    @learner = current_learner
    @type = history_type
    
    @list_title = "Learning History (#{@type})"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
  end
    
end
