# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class AnswerTest < ActiveSupport::TestCase

  context "Creating a new answer" do
    should belong_to(:question)
    should belong_to(:learner)
    should validate_presence_of(:question)
    should validate_presence_of(:value)
    should validate_presence_of(:learner)
  end
  
end
