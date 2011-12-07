# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class RecommendedEvent < ActiveRecord::Base
  belongs_to :recommendation
  belongs_to :event
end
