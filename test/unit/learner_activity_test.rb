require 'test_helper'

class LearnerActivityTest < ActiveSupport::TestCase
  should "be valid" do
    assert LearnerActivity.new.valid?
  end
end
