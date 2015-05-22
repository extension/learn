# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class LearnersController < ApplicationController
  before_filter :authenticate_portfolio_if_not_public, only: [:portfolio]
  before_filter :authenticate_learner!, except: [:portfolio]
  
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
    return record_not_found if !@learner
    
    @attended_events = @learner.events.active.attended.order("event_connections.created_at DESC").limit(5)
    @watched_events = @learner.events.active.watched.order("event_connections.created_at DESC").limit(5)
    @presented_events = @learner.presented_events.active.order("session_start DESC").limit(5)
    @bookmarked_events = @learner.events.active.bookmarked.order("event_connections.created_at DESC").limit(5)
    @commented_events = @learner.commented_events.order("created_at DESC").limit(5)
    @presented_conferences = @learner.presented_conferences
    @attended_conferences = @learner.conferences.attended
  end
  
  def learning_history
    @learner = current_learner
    prepare_history('Activity')
    @list_title = "Your Activity Log"
    # don't think there's a better AR way of doing this, it's pretty fast as is 
    @activities = @learner.activity_logs.select("activity_logs.created_at AS created_at, ea.*, e.title AS title, e.id AS event_id").joins("JOIN event_activities AS ea on ea.id = activity_logs.loggable_id JOIN events as e on e.id = ea.event_id").where("e.is_canceled = 0 AND activity_logs.loggable_type = 'EventActivity' AND ea.activity IN (#{EventActivity::HISTORY_ITEMS.join(',')})").order("activity_logs.created_at DESC").page(params[:page])
  end
  
  def presented_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Presented')
    @events = @learner.presented_events.active.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end
  
  def created_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Created')
    @events = @learner.created_events.active.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end
  
  def attended_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Attended')
    @events = @learner.events.active.attended.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end
  
  def watched_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Watched')
    @events = @learner.events.active.watched.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end
  
  def bookmarked_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Bookmarked')
    @list_title = "Followed by #{@learner.name}"
    @events = @learner.events.active.bookmarked.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end
  
  def comment_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Commented')
    @events = @learner.commented_events.active.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end
  
  def token_search
    @learners = Learner.where("name like ?", "%#{params[:q]}%")
    token_hash = @learners.collect{|learner| {id: learner.id, name: learner.name}}
    render(json: token_hash)
  end

  def register_learner
    if learner = Learner.where(email: params[:email]).first
      begin
        EventConnection.create! learner_id: learner.id, event_id: params[:event_id], connectiontype: 6
        rescue ActiveRecord::RecordInvalid => e
      end
    else
      learner = Learner.create! email: params[:email], name: params[:first_name] + " " + params[:last_name]
      EventConnection.create! learner_id: learner.id, event_id: params[:event_id], connectiontype: 6
    end
    render :text => nil
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
