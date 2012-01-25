# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class PresenterConnection < ActiveRecord::Base
  belongs_to :event
  belongs_to :learner  
  after_create :create_bookmark
  after_create :log_object_activity


  scope :event_date_filtered, lambda { |start_date,end_date| includes(:event).where('DATE(events.session_start) >= ? AND DATE(events.session_start) <= ?', start_date, end_date) }

  def log_object_activity
    EventActivity.log_object_activity(self)
  end
  
  def create_bookmark
    begin
      EventConnection.create(learner: self.learner, event: self.event, connectiontype: EventConnection::BOOKMARK)
    rescue ActiveRecord::RecordNotUnique => e
      # do nothing, already bookmarked
    end
  end
end