# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

FactoryGirl.define do
  factory :recommended_event do
    association :recommendation
    association :event
  end
end