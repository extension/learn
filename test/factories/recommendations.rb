# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

FactoryGirl.define do
  factory :recommendation do
    association :learner
    day Date.today
  end
end