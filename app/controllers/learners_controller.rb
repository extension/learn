# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class LearnersController < ApplicationController
  
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
    @learner = Learner.find_by_id(params[:id])
    @list_title = 'Attended Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = @learner.events.attended.paginate(:page => params[:page]).order("event_connections.created_at DESC")
  end
  
  def attended
    @learner = Learner.find_by_id(params[:id])
    @list_title = 'Attended Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = @learner.events.attended.paginate(:page => params[:page]).order("event_connections.created_at DESC")
    render :action => 'index'
  end
  
  def presented
    @learner = Learner.find_by_id(params[:id])
    @list_title = 'Presented Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = @learner.presented_events.paginate(:page => params[:page]).order("session_start DESC")
    render :action => 'index'
  end
  
  def watched
    @learner = Learner.find_by_id(params[:id])
    @list_title = 'Watched Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = @learner.events.watched.paginate(:page => params[:page]).order("event_connections.created_at DESC")
    render :action => 'index'
  end
  
  def bookmarked
    @learner = Learner.find_by_id(params[:id])
    @list_title = 'Bookmarked Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = @learner.events.bookmarked.paginate(:page => params[:page]).order("event_connections.created_at DESC")
    render :action => 'index'
  end
  
end
