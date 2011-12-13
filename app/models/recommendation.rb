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
    
end
