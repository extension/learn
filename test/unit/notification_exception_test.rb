require 'test_helper'

class NotificationExceptionTest < ActiveSupport::TestCase
  should "be valid" do
    assert NotificationException.new.valid?
  end
end
