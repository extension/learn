require 'test_helper'

class LearnerTest < ActiveSupport::TestCase
  should "be valid" do
    assert Learner.new.valid?
  end
end
