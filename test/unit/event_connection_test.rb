require 'test_helper'

class EventConnectionTest < ActiveSupport::TestCase
  should "be valid" do
    assert EventConnection.new.valid?
  end
end
