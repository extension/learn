# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class PresenterConnection < ActiveRecord::Base
  belongs_to :event
  belongs_to :learner
  acts_as_list scope: :event

  after_create :create_follow

  scope :event_date_filtered, lambda { |start_date,end_date| includes(:event).where('DATE(events.session_start) >= ? AND DATE(events.session_start) <= ?', start_date, end_date) }

  def dump_activities
    self.event_activities.destroy_all
  end

  def create_follow
    begin
      EventConnection.create(learner: self.learner, event: self.event, connectiontype: EventConnection::FOLLOW)
    rescue ActiveRecord::RecordNotUnique => e
      # do nothing, already following
    end
  end
end
