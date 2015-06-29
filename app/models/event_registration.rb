# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventRegistration < ActiveRecord::Base
  belongs_to :event

  # define accessible attributes
  attr_accessible :first_name, :last_name, :email, :event_id

  #validations
  validates :event_id, :uniqueness => {:scope => :email}
end