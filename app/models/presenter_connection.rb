# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class PresenterConnection < ActiveRecord::Base
  belongs_to :event
  belongs_to :learner  
  after_create :log_object_activity

  def log_object_activity
    EventActivity.log_object_activity(self)
  end
end