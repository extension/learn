# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Conferences::DataController < ApplicationController
  before_filter :check_for_conference
  before_filter :authenticate_learner!

  def index
  end

  def events
    if(!params[:download].nil? and params[:download] == 'csv')
      @events = @conference.events.includes([:tags, :presenters]).order("session_start ASC")
      response.headers['Content-Type'] = 'text/csv; charset=iso-8859-1; header=present'
      response.headers['Content-Disposition'] = 'attachment; filename=event_statistics.csv'
      render(:template => '/conferences/data/events_csvlist', :layout => false)
    else
      @events = @conference.events.includes([:tags, :presenters]).order("session_start ASC")
    end
  end

  def evaluation
  end

  def evaluationbysession
    @event_counts = EvaluationAnswer.group(:event).count('DISTINCT(learner_id)')
  end

  protected

  def check_for_conference
    if(params[:conference_id])
      @conference = Conference.find_by_id_or_hashtag(params[:conference_id])

      if(@conference)
        # if not a virtual conference - force the timezone to be
        # that of the conference
        if(!@conference.is_virtual?)
          Time.zone = @conference.time_zone
        end
      end
    end
  end

end
