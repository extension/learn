# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class LearnersController < ApplicationController
  before_filter :authenticate_portfolio_if_not_public, only: [:portfolio]
  before_filter :authenticate_learner!, except: [:index, :portfolio]
  
  def index
  end
  
  def block
    @learner = Learner.find_by_id(params[:id])
    @learner.retired = true
    @learner.is_blocked = true
    Notification.create(notifiable: @learner, notificationtype: Notification::LEARNER_RETIRED, delivery_time: 1.minute.from_now) unless @learner.nil?
    @learner.save
    
    LearnerActivity.log_block(current_learner, @learner)
    flash[:notice] = "Learner successfully blocked."
    redirect_to portfolio_learner_url(@learner.id)
  end
  
  def unblock
    @learner = Learner.find_by_id(params[:id])
    @learner.retired = false
    @learner.is_blocked = false
    @learner.save
    
    LearnerActivity.log_unblock(current_learner, @learner)
    flash[:notice] = "Learner successfully unblocked."
    redirect_to portfolio_learner_url(@learner.id)
  end
  
  def portfolio
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => [:portfolio_setting, :preferences])
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
  
    @attended_events = @learner.events.active.attended.order("event_connections.created_at DESC").limit(5)
    @watched_events = @learner.events.active.watched.order("event_connections.created_at DESC").limit(5)
    @presented_events = @learner.presented_events.active.order("session_start DESC").limit(5)
    @bookmarked_events = @learner.events.active.bookmarked.order("event_connections.created_at DESC").limit(15)
  end
  
  def learning_history
    @learner = current_learner
    prepare_history('Activity')
    @list_title = "Your Activity Log"
    # don't think there's a better AR way of doing this, it's pretty fast as is 
    @activities = @learner.activity_logs.select("activity_logs.created_at AS created_at, ea.*, e.title AS title, e.id AS event_id").joins("JOIN event_activities AS ea on ea.id = activity_logs.loggable_id JOIN events as e on e.id = ea.event_id").where("e.is_canceled = 0 AND activity_logs.loggable_type = 'EventActivity' AND ea.activity IN (#{EventActivity::HISTORY_ITEMS.join(',')})").paginate(:page => params[:page]).order("activity_logs.created_at DESC")
  end
  
  def presented_history
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :preferences)
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
    prepare_history('Presented')
    @events = @learner.presented_events.active.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def attended_history
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :preferences)
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
    
    prepare_history('Attended')
    @events = @learner.events.active.attended.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def watched_history
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :preferences)
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
    
    prepare_history('Watched')
    @events = @learner.events.active.watched.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def bookmarked_history
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :preferences)
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
    
    prepare_history('Bookmarked')
    @events = @learner.events.active.bookmarked.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def commented_history
    #@learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :preferences)
    #if @learner.blank?
    #  flash[:error] = "Invalid Learner Specified"
    #  return redirect_to root_url
    #end
    
    @learner = current_learner
    prepare_history('Commented')
    @events = @learner.commented_events.active.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def rated_history
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :preferences)
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
    
    prepare_history('Rated')
    @events = @learner.rated_events.active.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end
  
  def answered_question_history    
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => :preferences)
    if @learner.blank?
      flash[:error] = "Invalid Learner Specified"
      return redirect_to root_url
    end
    
    prepare_history('Answered Questions')
    @events = @learner.events_answered.active.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'learning_history'
  end

  private
  
  def prepare_history(history_type)
    @type = history_type
    @list_title = "#{@type} by #{@learner.name}"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
  end
  
  def authenticate_portfolio_if_not_public
    if params[:id] && learner = Learner.find_by_id(params[:id]) 
      if learner.public_portfolio?
        return
      end
    end
    
    authenticate_learner!
  end
    
end
