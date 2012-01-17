# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class RecommendedEvent < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.urlwriter_host
  
  scope :this_week, lambda {
    weekday = Time.now.utc.strftime('%u').to_i
    # if saturday or sunday - do next week, else this week
    if(weekday >= 6)
      includes('event').where('events.session_start > ?',(Time.zone.now + 7.days).beginning_of_week).where('events.session_start <= ?', (Time.zone.now + 7.days).end_of_week)
    else
      includes('event').where('events.session_start > ?',Time.zone.now.beginning_of_week).where('events.session_start <= ?', Time.zone.now.end_of_week)
    end
  }
  
  scope :last_week, lambda {
    weekday = Time.now.utc.strftime('%u').to_i
    # if saturday or sunday - do this week, else last week
    if(weekday >= 6)
      includes('event').where('events.session_start > ?',Time.zone.now.beginning_of_week).where('events.session_start <= ?', Time.zone.now.end_of_week)
    else
      includes('event').where('events.session_start > ?',(Time.zone.now - 7.days).beginning_of_week).where('events.session_start <= ?', (Time.zone.now - 7.days).end_of_week)
    end
  }
  
  belongs_to :recommendation
  belongs_to :event
  
  def url
    recommended_event_url(self)
  end
  
end
