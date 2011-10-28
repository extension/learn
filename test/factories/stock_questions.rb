# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

FactoryGirl.define do
  sequence :stockquestionprompt do |integer_value|
    "This is stock question prompt ##{integer_value}"
  end
  
    
  factory :stock_question do
    prompt {Factory.next(:stockquestionprompt)}
    active true
    association :creator, :factory => :learner 
  end
end