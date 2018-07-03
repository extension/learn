# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class SearchController < ApplicationController
  before_filter :signin_required, only: [:learners]
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
        return redirect_to(event_path(event))
      end
    end

    @all_list_title = "Search Results for '#{params[:q]}'"

    self.events

    self.learners

    render :action => 'index'
  end

  def events
    @events = EventsIndex.not_canceled_or_deleted.globalsearch(params[:q]).order(session_start: :desc).page(params[:page]).load
    @list_title = "Search Results for '#{params[:q]}' in Events"
  end

  def learners
    @learners = LearnersIndex.not_retired.by_name(params[:q]).page(params[:page]).load
    @list_title = "Search Results for '#{params[:q]}' in Learners"
  end

end
