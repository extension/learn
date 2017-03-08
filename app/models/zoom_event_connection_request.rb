# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomEventConnectionRequest < ActiveRecord::Base
  attr_accessible :event, :event_id, :request_type, :connection_count, :success, :completed_at

  belongs_to :event

  # request types
  REQUEST_REGISTRANTS = 'registrants'
  REQUEST_ATTENDEES = 'attendees'


end
