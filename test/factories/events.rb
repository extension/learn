# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

FactoryGirl.define do
  sequence :event_location_url do |integer_value|
    "http://learn.dev/test_location/#{integer_value}"
  end
  
  factory :event do
    title 'A Test Event'
    description 'An example learn event description'
    session_start Time.parse('2011-10-28 16:42 EDT')
    session_length 30
    location {Factory.next(:event_location_url)}
  end
end
