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
  
    @attended_events = @learner.events.attended.order("event_connections.created_at DESC")#.limit(5)
    @watched_events = @learner.events.watched.order("event_connections.created_at DESC")#.limit(5)
    @bookmarked_events = @learner.events.bookmarked.order("event_connections.created_at DESC")#.limit(5)
    @presented_events = @learner.presented_events.order("session_start DESC")#.limit(5)
  end
  
  def edit
    @learner = Learner.find_by_id(params[:id])
  end
  
  def update
    @learner = Learner.find_by_id(params[:id])
    if @learner.update_attributes(params[:learner])
      redirect_to(edit_learner_url(@learner), :notice => 'Event was successfully updated.')
    else
      render :action => 'edit'
    end
  end
  
  def learning_history  
  end
  
end
