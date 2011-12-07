# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

# it's like a recommendation, but you know, not.
class ExampleRecommendation
  attr_accessor :learner
  attr_accessor :upcoming_limit
  attr_accessor :recent_limit
  
  def initialize(learner = Learner.learnbot)
    @learner = learner
  end
  
  def upcoming
    Event.upcoming(limit=self.upcoming_limit)
  end
  
  def recent
    Event.recent(limit=self.recent_limit)
  end
  
  def upcoming_limit
    @upcoming_limit || 4
  end
  
  def recent_limit
    @recent_limit || 4
  end
  
end
