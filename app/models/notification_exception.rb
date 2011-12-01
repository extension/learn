# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class NotificationException < ActiveRecord::Base
  belongs_to :event
  belongs_to :learner
  has_many :event_activities, :as => :trackable, dependent: :destroy

  after_create :log_object_activity


  def log_object_activity
    EventActivity.log_object_activity(self)
  end
end
