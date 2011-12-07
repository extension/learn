# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Recommendation < ActiveRecord::Base
  belongs_to :learner
  has_many :recommended_events
  has_many :events, :through => :recommended_events
end
