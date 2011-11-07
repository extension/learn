# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :learner
  has_one :event, :through => :question
  
  validates :value, :presence => true
  validates :question, :presence => true
  validates :learner, :presence => true

end
