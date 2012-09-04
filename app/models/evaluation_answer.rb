# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EvaluationAnswer < ActiveRecord::Base
  belongs_to :evaluation_question
  belongs_to :learner
  belongs_to :event    

  attr_accessible :event, :event_id, :learner, :learner_id, :response, :secondary_response, :value, :evaluation_question_id, :evaluation_question

end
