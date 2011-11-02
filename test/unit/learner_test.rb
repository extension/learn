require 'test_helper'

class LearnerTest < ActiveSupport::TestCase

  context "Creating a new learner" do
    should have_many(:ratings)
    should have_many(:authmaps)
    should have_many(:comments)
    should have_many(:event_connections)
    should have_many(:events)
  end

end
