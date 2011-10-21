# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Session < ActiveRecord::Base
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings
  
end
