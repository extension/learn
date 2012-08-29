# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Feeds::EventsController < ApplicationController
  
  def index
    # TODO: tag lookups and limits and any other params - maybe
    @eventlist = Event.nonconference.active.order('updated_at DESC').limit(Settings.default_feed_items)
    respond_to do |format|
      format.xml { render :layout => false, :content_type => "application/atom+xml" }
    end
  end
  
  def show
    if(!(@event = Event.find_by_id(params[:id])))
      @errormessage = "Unable to find the specified event."
      return render :template => 'feeds/events/error', :layout => false, :content_type => "application/atom+xml"
    end
    return render :layout => false, :content_type => "application/atom+xml"
  end

end
