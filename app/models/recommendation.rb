# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Recommendation < ActiveRecord::Base
  belongs_to :learner
  has_many :recommended_events
  has_many :events, :through => :recommended_events
  
  before_create :set_day
  after_create  :create_notification
  
  def upcoming
    self.recommended_events.this_week
  end
  
  def recent
    self.recommended_events.last_week
  end
  
  def set_day
    if(self.day.blank?)
      self.day = Date.today
    end
  end
  
  def self.create_from_epoch
    learners_events = Learner.recommended_events
    learners_events.each do |learner,eventlist|
      recommendation = self.create(learner: learner)
      recommendation.events = eventlist
    end
  end
  
  def create_notification
    Notification.create(notificationtype: Notification::RECOMMENDATION, notifiable: self, delivery_time: self.class.delivery_time(self.learner.time_zone))
  end
  
  def self.delivery_time(time_zone)
    # get date of next monday, utc
    monday = (Time.now.utc + 7.days).beginning_of_week
    Time.zone = time_zone
    monday_four_am = Time.zone.parse("#{monday.to_date} 04:00:00")
    now = Time.zone.now
    (monday_four_am > now) ? monday_four_am : now
  end
        

end
