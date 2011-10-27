# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :creator, :class_name => 'Learner'
  
  validates :value, :presence => true
  validates :question, :presence => true
  validates :creator, :presence => true
end
