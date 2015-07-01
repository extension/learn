# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'csv'

class EventRegistration < ActiveRecord::Base
  belongs_to :event

  # define accessible attributes
  attr_accessible :first_name, :last_name, :email, :event_id

  #validations
  validates :event_id, :uniqueness => {:scope => :email}

  def self.export(registrants)
  	CSV.generate do |csv|
      headers = []
      headers << 'First Name'
      headers << 'Last Name'
      headers << 'Email'
      headers << 'Date Registered'
      csv << headers
      registrants.each do |registrant|
        row = []
        row << registrant.first_name
        row << registrant.last_name
        row << registrant.email
        row << registrant.created_at
        csv << row
      end
		end
  end
end