require 'test_helper'

class ActivityLogTest < ActiveSupport::TestCase
  should "be valid" do
    assert ActivityLog.new.valid?
  end
end
