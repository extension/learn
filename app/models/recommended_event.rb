# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class RecommendedEvent < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host
  
  scope :upcoming, lambda { |limit=3| includes('event').where('events.session_start >= ?',Time.zone.now).order("events.session_start ASC").limit(limit) }
  scope :recent,   lambda { |limit=3| includes('event').where('events.session_start < ?',Time.zone.now).order("events.session_start DESC").limit(limit) }
  
  belongs_to :recommendation
  belongs_to :event
  
  def url
    recommended_event_url(self)
  end
  
end
