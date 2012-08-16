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

end