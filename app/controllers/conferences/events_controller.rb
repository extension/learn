# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Conferences::EventsController < ApplicationController
  before_filter :set_conference
  before_filter :authenticate_learner!, only: [:edit, :update, :new, :create]

  def index
    @list_title = 'All Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = @conference.events.active.order('session_start ASC').page(params[:page])
  end

  def show
    @event = Event.find(params[:id])
    return if check_for_event_redirect

    # dup of global before filter logic in order
    # to force display of event time in the time zone of the session
    if(!@conference.is_virtual?)
      Time.zone = @conference.time_zone
    elsif(current_learner and current_learner.has_time_zone?)
      Time.zone = current_learner.time_zone
    else
      Time.zone = @event.time_zone
    end

    @comments = @event.comments
    # log view
    EventActivity.log_view(current_learner,@event) if(current_learner)
  end

  def new
    @event = Event.new
    # seed defaults
    if(current_learner)
      @event.time_zone = Time.zone
    end
  end
  
  def create
    @event = Event.new(params[:event])
    @event.conference = @conference
    @event.last_modifier = @event.creator = current_learner
    if @event.save
      redirect_to(@event, :notice => 'Event was successfully created.')
    else
      render :action => 'edit'
    end
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])
    update_params = params[:event].merge({last_modifier: current_learner})
    if @event.update_attributes(update_params)
      redirect_to(@event, :notice => 'Event was successfully updated.')
    else
      render :action => 'edit'
    end        
  end

  def rooms

  end

  protected

  def set_conference
    @conference = Conference.find(params[:conference_id])

    # if not a virtual conference - force the timezone to be
    # that of the conference
    if(!@conference.is_virtual?)
      Time.zone = @conference.time_zone
    end
  end

  # must have @event and @conference
  def check_for_event_redirect
    if(@event.event_type == Event::CONFERENCE)
      if(@event.conference != @conference)
        redirect_to(conference_event_url(:conference_id => @event.conference.id, :id => @event.id))
        return true
      else
        return false
      end
    elsif(@event.event_type == Event::BROADCAST)
      # set the canonical to the event path
      @canonical_link = event_url(@event)
      return false
    else
      redirect_to(event_url(@event))
      return true
    end
  end

  # must have @event and @conference
  def check_for_event_redirect
    if(@event.event_type == Event::CONFERENCE)
      if(@event.conference != @conference)
        redirect_to(conference_event_url(:conference_id => @event.conference.id, :id => @event.id))
        return true
      else
        return false
      end
    elsif(@event.event_type == Event::BROADCAST)
      # set the canonical to the event path
      @canonical_link = event_url(@event)
      return false
    else
      redirect_to(event_url(@event))
      return true
    end
  end



end