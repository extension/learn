class WidgetsController < ApplicationController
  
  def front_porch
    @title = "eXtension Upcoming Events"
    @path_to_upcoming_events = upcoming_events_url
    
    if params[:limit].blank? || params[:limit].to_i <= 0
      event_limit = 5
    else
      event_limit = params[:limit].to_i
    end
    
    if params[:width].blank? || params[:width].to_i <= 0
      @width = 300
    else
      @width = params[:width].to_i
    end
    
    @event_list = Event.featured.nonconference.active.upcoming(limit = event_limit)
  
    render "widgets"
  end
  
  def upcoming
    
  end
  
end
