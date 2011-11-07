# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class ActivityLogTest < ActiveSupport::TestCase

  context "Creating a new activity" do
    should belong_to(:learner)
    should belong_to(:event)
    should belong_to(:loggable)
    should validate_presence_of(:learner)
  end
  
end
