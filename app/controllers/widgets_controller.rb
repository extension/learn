class WidgetsController < ApplicationController
  
  def front_porch
    @title = "eXtension Upcoming Learn Events"
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
    
    @path_to_upcoming_events = upcoming_events_url
      
    if params[:tags].present?  
      @tag_list = params[:tags].split(',')
      @title = "eXtension Upcoming Learn Events in #{@tag_list.join(',')}"
      if params[:operator].present?
        if params[:operator].downcase == 'and'
          @event_list = Event.featured.nonconference.active.upcoming(limit = event_limit).tagged_with_all(@tag_list)
        end
      elsif params[:operator].blank? || params[:operator].downcase != 'and'
        @event_list = Event.featured.nonconference.active.upcoming(limit = event_limit).tagged_with(params[:tags])
      end
    else
      @title = "eXtension Upcoming Learn Events"
      @event_list = Event.featured.nonconference.active.upcoming(limit = event_limit)
    end
    
    render "widgets"
  end
  
end
