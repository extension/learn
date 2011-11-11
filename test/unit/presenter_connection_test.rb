require 'test_helper'

class PresenterConnectionTest < ActiveSupport::TestCase
  should "be valid" do
    assert PresenterConnection.new.valid?
  end
end
