# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class HomeController < ApplicationController
  
  def index
    @upcoming_events = Event.active.upcoming(limit = 3)
    @recent_events = Event.active.recent(limit = 8)
    @more_upcoming_events = Event.active.upcoming(limit = 8, offset = 3)
  end
  
  def contact_us
    return render :template => 'home/contact_us.html.erb'
  end
  
  def retired
    return render :template => 'home/retired.html.erb'
  end
  
  def exid
    return render :template => 'home/exid.html.erb'
  end

end
