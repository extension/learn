# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventsController < ApplicationController
  
  
  def show
    @event = Event.find(params[:id])
  end
end
