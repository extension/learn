ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'test_sunspot'
# stub out the sunspot to a proxy
TestSunspot.setup

class ActionController::TestCase
  include TestSunspot # adds startup/shutdown to tests to start a test sunspot server
  include Devise::TestHelpers
end

class ActiveSupport::TestCase
  include TestSunspot # adds startup/shutdown to tests to start a test sunspot server
    
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

