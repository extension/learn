# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Feeds::EventsController < ApplicationController

  def index
    # TODO: tag lookups and any other params - maybe
    @eventlist = Event.nonconference.active.order('updated_at DESC').limit(((params[:limit].present?) && (params[:limit].to_i > 0)) ? params[:limit] : Settings.default_feed_items)
    @title = "eXtension Professional Development Sessions"
    respond_to do |format|
      format.xml { render :layout => false, :content_type => "application/atom+xml" }
    end
  end

  def upcoming
    if params[:limit].present? && (params[:limit].to_i > 0)
      event_limit = params[:limit]
    else
      event_limit = 5
    end

    @eventlist = Event.nonconference.active.upcoming(limit = event_limit)
    @title = "Upcoming eXtension Professional Development Sessions"

    respond_to do |format|
      format.xml { render :template => '/feeds/events/index', :layout => false, :content_type => "application/atom+xml" }
    end
  end


  def tags
    if params[:limit].present? && (params[:limit].to_i > 0) && params[:limit].to_i <= Settings.max_feed_items
      @limit = params[:limit].to_i
    else
      @limit = Settings.default_feed_items
    end

    if(params[:tags])
      @list_title = "Sessions Tagged With '#{params[:tags]}'"
      if params[:type].present?
        if params[:type] == 'recent'
          @title = "Recent #{@list_title}"
          @events = Event.includes(:tags).active.recent.tagged_with(params[:tags]).order('session_start DESC')
        elsif params[:type] == 'upcoming'
          @title = "Upcoming #{@list_title}"
          @eventlist = Event.includes(:tags).active.upcoming.tagged_with(params[:tags]).order('session_start DESC')
        else
          @eventlist = Event.includes(:tags).active.tagged_with(params[:tags]).order('session_start DESC')
        end
      else
        @eventlist = Event.includes(:tags).active.tagged_with(params[:tags]).order('session_start DESC')
      end
    else
      @title = "eXtension Professional Development Sessions"
      @eventlist = Event.includes(:tags).active.order('session_start DESC')
    end

    respond_to do |format|
      format.xml { render :template => '/feeds/events/index', :layout => false, :content_type => "application/atom+xml" }
    end
  end


end
