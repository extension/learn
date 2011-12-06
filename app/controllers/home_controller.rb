# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class HomeController < ApplicationController
  
  def index
    @upcoming_events = Event.find(:all, :conditions => "session_start > '#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}'", :limit => 3, :order => "session_start ASC")
    @recent_events = Event.find(:all, :conditions => "session_start < '#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}'", :limit => 15, :order => "session_start DESC")
  end

end
