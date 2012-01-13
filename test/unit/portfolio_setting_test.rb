require 'test_helper'

class LearningPortfolioTest < ActiveSupport::TestCase
  should "be valid" do
    assert LearningPortfolio.new.valid?
  end
end
