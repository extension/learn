# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :learner
  belongs_to :event, :through => :question
  
  validates :value, :presence => true
  validates :question, :presence => true
  validates :learner, :presence => true

end
