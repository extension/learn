require 'test_helper'

class MailerCacheTest < ActiveSupport::TestCase
  should "be valid" do
    assert MailerCache.new.valid?
  end
end
