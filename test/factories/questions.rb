# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

FactoryGirl.define do
  sequence :questionprompt do |integer_value|
    "This is question prompt ##{integer_value}"
  end
  
    
  factory :question do
    prompt {Factory.next(:questionprompt)}
  end
end

