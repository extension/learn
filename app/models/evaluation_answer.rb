# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EvaluationAnswer < ActiveRecord::Base
  belongs_to :evaluation_question
  belongs_to :learner
  belongs_to :event    
end
