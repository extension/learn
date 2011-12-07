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
    self.events.upcoming
  end
  
  def recent
    self.events.recent
  end
  
  def set_day
    if(self.day.blank?)
      self.day = Date.today
    end
  end
end
