require 'test_helper'

class RecommendationTest < ActiveSupport::TestCase
  should "be valid" do
    assert Recommendation.new.valid?
  end
end
