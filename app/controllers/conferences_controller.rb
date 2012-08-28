# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ConferencesController < ApplicationController

  def index
  end

  def show

    # will raise ActiveRecord::RecordNotFound if not found
    @conference = Conference.find_by_id_or_hashtag(params[:id])

    # redirect check
    if(params[:id].to_i > 0 )
      # got here via an id - redirect to the hashtag url
      return redirect_to(conference_url(:id => @conference.hashtag), :status => :moved_permanently)
    end

  end

  def index
    @list_title = 'All Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = @conference.events.active.order('session_start ASC').page(params[:page])
  end

end