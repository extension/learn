# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class EventConnectionTest < ActiveSupport::TestCase
  should "be valid" do
    assert EventConnection.new.valid?
  end
end
