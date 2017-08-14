# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Comment < ActiveRecord::Base
  belongs_to :learner
  belongs_to :event
  has_many :event_activities, :as => :trackable, dependent: :destroy
  after_create :log_object_activity
  after_create :schedule_activity_notification
  after_save :update_counter_cache
  after_destroy :update_counter_cache

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

  def created_by_blocked_learner?
    return true if self.learner.is_blocked
    return false
  end

  def is_reply?
    !self.is_root?
  end

  def schedule_activity_notification
    if !Notification.pending_activity_notification?(self.event)
      Notification.create(notifiable: self.event, notificationtype: Notification::COMMENT, delivery_time: Notification::ACTIVITY_NOTIFICATION_INTERVAL.from_now)
    end
    if self.is_reply?
      Notification.create(notifiable: self, notificationtype: Notification::COMMENT_REPLY, delivery_time: 1.minute.from_now) unless self.learner == self.parent.learner
    end
  end

  def update_counter_cache
    self.event.update_column(:commentators_count, self.event.commentators.count)
  end

end
