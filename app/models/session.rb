# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Session < ActiveRecord::Base
  has_many :tags, :as => :taggable
  
end
