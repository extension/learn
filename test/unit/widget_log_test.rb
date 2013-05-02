require 'test_helper'

class WidgetLogTest < ActiveSupport::TestCase
  should "be valid" do
    assert WidgetLog.new.valid?
  end
end
