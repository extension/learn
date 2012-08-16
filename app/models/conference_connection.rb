# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ConferenceConnection < ActiveRecord::Base
  belongs_to :learner
  belongs_to :conference
  
end