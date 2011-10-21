require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  should "be valid" do
    assert Tagging.new.valid?
  end
end
