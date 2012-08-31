# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ConferencesController < ApplicationController
  before_filter :authenticate_learner!, only: [:edit, :update]

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

  def edit
    @conference = Conference.find_by_id_or_hashtag(params[:id])
  end
  
  def update
    @conference = Conference.find_by_id_or_hashtag(params[:id])
    update_params = params[:conference].merge({last_modifier: current_learner})
    if @conference.update_attributes(update_params)
      redirect_to(@conference, :notice => 'Conference was successfully updated.')
    else
      render :action => 'edit'
    end        
  end

  def allevents
    @conference = Conference.find_by_id_or_hashtag(params[:id])
    @events = @conference.events.order('session_start ASC')
  end

  def makeconnection
    @conference = Conference.find_by_id_or_hashtag(params[:id])
    if(connectiontype = params[:connectiontype])
      case connectiontype.to_i
      when ConferenceConnection::ATTEND
        if(params[:wantsconnection] and params[:wantsconnection] == '1')
          current_learner.connect_with_conference(@conference,ConferenceConnection::ATTEND)
        else
          current_learner.remove_connection_with_conference(@conference,ConferenceConnection::ATTEND)
        end
      else
        # do nothing
      end
    end
  end


end