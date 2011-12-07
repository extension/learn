require 'test_helper'

class RecommendedEventTest < ActiveSupport::TestCase
  should "be valid" do
    assert RecommendedEvent.new.valid?
  end
end
