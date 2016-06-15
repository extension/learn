# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class HomeController < ApplicationController

  def index
    tracker do |t|
      t.google_tag_manager :push, { pageCategory: 'home'}
    end

    @upcoming_events = Event.nonconference.active.upcoming(limit = 3)
    @recent_events = Event.nonconference.active.recent(limit = 8)
    @more_upcoming_events = Event.nonconference.active.upcoming(limit = 8, offset = 3)

    # temporary! nexc2012 link
    @nexc2012 = Conference.find_by_hashtag('nexc2012')
  end

  def contact_us
    return render :template => 'home/contact_us.html.erb'
  end

  def retired
    return render :template => 'home/retired.html.erb'
  end

  def hosting
    return render :template => 'home/hosting.html.erb'
  end

end
