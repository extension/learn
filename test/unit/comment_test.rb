require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should "be valid" do
    assert Comment.new.valid?
  end
end
