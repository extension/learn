require 'test_helper'

class PreferenceTest < ActiveSupport::TestCase
  should "be valid" do
    assert Preference.new.valid?
  end
end
