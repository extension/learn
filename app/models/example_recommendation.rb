# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

# it's like a recommendation, but you know, not.
class ExampleRecommendation
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host
  
  attr_accessor :learner
  attr_accessor :upcoming_limit
  attr_accessor :recent_limit
  
  def initialize(options = {})
    @learner = options[:learner] || Learner.learnbot
    @upcoming_limit = options[:upcoming_limit] || 3
    @recent_limit = options[:recent_limit] || 3
  end
  
  def upcoming
    build_recommended_events_from_events(Event.upcoming(limit=self.upcoming_limit))
  end
  
  def recent
    build_recommended_events_from_events(Event.recent(limit=self.recent_limit))
  end
  
  # used to create pretend recommendation events
  def build_recommended_events_from_events(events)
    recommended_event_list = []
    events.each do |event|
      recommended_event_list << OpenStruct.new(event: event, url: event_url(event))
    end
    recommended_event_list
  end
  
end
