# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

# it's like a recommendation, but you know, not.
class ExampleRecommendation
  attr_accessor :learner
  
  def initialize(learner = Learner.learnbot)
    @learner = learner
  end
  
  def upcoming
    Event.upcoming(limit=4)
  end
  
  def recent
    Event.recent(limit=4)
  end
  
end
