# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Comment < ActiveRecord::Base
  belongs_to :learner
  belongs_to :event
  has_many :ratings, :as => :rateable, :dependent => :destroy
  has_many :raters, :through => :ratings, :source => :learner
  has_many :event_activities, :as => :trackable, dependent: :destroy
  after_create :log_object_activity
  after_create :schedule_activity_notification
  
  # make sure to keep this callback ahead of has_ancestry, which has its own callbacks for destroy
  before_destroy :set_orphan_flag_on_children
  
  # using the ancestry gem for threaded comments
  # orphan strategy will move the parent's children up a level in the hierarchy if the parent gets deleted
  has_ancestry :orphan_strategy => :rootify
  
  validates :content, :learner_id, :event_id, :presence => true
  
  def log_object_activity
    EventActivity.log_object_activity(self)
  end
  
  def set_orphan_flag_on_children
    self.children.update_all(parent_removed: true)
  end
  
  def is_reply?
    !self.is_root?
  end
  
  def schedule_activity_notification
    Notification.create(notifiable: self.event, notificationtype: Notification::ACTIVITY, delivery_time: 1.minute.from_now)
  end
end
