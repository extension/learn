require 'test_helper'

class MaterialLinkTest < ActiveSupport::TestCase
  should "be valid" do
    assert MaterialLink.new.valid?
  end
end
