# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventConnection < ActiveRecord::Base
  belongs_to :event
  belongs_to :learner
    
  PRESENTER = 2
  INTERESTED = 3
  ATTENDED = 4
  WILLATTEND = 5
  WATCH = 6
  

end
