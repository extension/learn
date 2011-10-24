require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should "be valid" do
    assert Session.new.valid?
  end
end
