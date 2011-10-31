require 'test_helper'

class RatingTest < ActiveSupport::TestCase
  should "be valid" do
    assert Rating.new.valid?
  end
end
