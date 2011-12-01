require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  should "be valid" do
    assert Notification.new.valid?
  end
end
