# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class SearchController < ApplicationController
  before_filter :authenticate_learner!, only: [:learners]
  def all
     # trash the utf8 param because google hates us.
    params.delete(:utf8)

    # take quotes out to see if it's a blank field and also strip out +, -, and "  as submitted by themselves are apparently special characters
    # for solr and will make it crash, and if you ain't got no q param, no search goodies for you!
    if !params[:q] || params[:q].gsub(/["'+-]/, '').strip.blank?
      flash[:error] = "Empty/invalid search terms"
      return redirect_to root_url
    end

    # special "id of event check"
    if (id_number = params[:q].cast_to_i) > 0
      if(event = Event.find_by_id(id_number))
        if(event.is_conference_session?)
          return redirect_to(conference_event_path(event,:conference_id => event.conference.hashtag))
        else
          return redirect_to(event_path(event))
        end
      end
    end

    @list_title = "Search Results for '#{params[:q]}'"

    self.events

    self.learners

    render :action => 'index'
  end

  def events
    events = Event.search do
                with(:is_canceled, false)
                fulltext(params[:q])
                order_by(:session_start, :desc)
                paginate :page => params[:page], :per_page => 10
              end
    @events = events.results
    @list_title = "Search Results for '#{params[:q]}' in Events"
  end

  def learners
    learners = Learner.search do
                with(:is_admin, false)
                with(:retired, false)
                fulltext(params[:q])
                paginate :page => params[:page], :per_page => 10
              end
    @learners = learners.results
    @list_title = "Search Results for '#{params[:q]}' in Learners"
  end

end
