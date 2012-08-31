# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ConferenceConnection < ActiveRecord::Base
  belongs_to :learner
  belongs_to :conference
  validates :learner_id, :uniqueness => {:scope => [:conference_id, :connectiontype]}

  attr_accessible :learner, :learner_id, :conference, :conference_id, :connectiontype, :role_description

  ATTEND = 1
  
end