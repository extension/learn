# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Feeds::EventsController < ApplicationController
  
  def index
    # TODO: tag lookups and any other params - maybe
    @eventlist = Event.nonconference.active.order('updated_at DESC').limit(((params[:limit].present?) && (params[:limit].to_i > 0)) ? params[:limit] : Settings.default_feed_items)
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
    respond_to do |format|
      format.xml { render :template => '/feeds/events/index', :layout => false, :content_type => "application/atom+xml" }
    end
  end
  
end
