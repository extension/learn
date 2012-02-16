# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class HomeController < ApplicationController
  
  def index
    @upcoming_events = Event.upcoming(limit = 3)
    @recent_events = Event.recent(limit = 15)
  end
  
  def contact_us
    return render :template => 'home/contact_us.html.erb'
  end
  
  def retired
    return render :template => 'home/retired.html.erb'
  end

end
