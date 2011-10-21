# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class TaggingTest < ActiveSupport::TestCase

  context "Creating a new tagging" do
    should belong_to(:tag)
    should belong_to(:taggable)
  end
  
end
