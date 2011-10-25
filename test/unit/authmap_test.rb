require 'test_helper'

class AuthmapTest < ActiveSupport::TestCase
  should "be valid" do
    assert Authmap.new.valid?
  end
end
