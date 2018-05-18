# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventConnection < ActiveRecord::Base
  belongs_to :event
  belongs_to :learner
  has_many :event_activities, :as => :trackable, dependent: :destroy
  validates :learner_id, :uniqueness => {:scope => [:event_id, :connectiontype]}

  FOLLOW = 3
  ATTEND = 4
  VIEW = 5

  after_create :log_connection
  after_save :update_counter_cache
  after_destroy :update_counter_cache

  def update_counter_cache
    case self.connectiontype
    when FOLLOW
      self.event.update_column(:followers_count, self.event.followers.count)
    when ATTEND
      self.event.update_column(:attendees_count, self.event.attendees.count)
    when VIEW
      self.event.update_column(:viewers_count, self.event.viewers.count)
    end
  end

  def log_connection
    EventActivity.log_connection(self)
  end
end
