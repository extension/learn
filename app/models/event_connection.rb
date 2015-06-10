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
      
  BOOKMARK = 3
  ATTEND = 4
  WATCH = 5
  
  after_create :log_object_activity
  after_save :update_counter_cache
  after_destroy :update_counter_cache

  def update_counter_cache
    case self.connectiontype
    when BOOKMARK
      self.event.update_column(:bookmarks_count, self.event.bookmarks.count)
    when ATTEND
      self.event.update_column(:attended_count, self.event.attended.count)
    when WATCH
      self.event.update_column(:watchers_count, self.event.watchers.count)
    end
  end

  def log_object_activity
    EventActivity.log_object_activity(self)
  end
end

