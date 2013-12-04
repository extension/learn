# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Image < ActiveRecord::Base
  attr_accessible :event_id, :file
  belongs_to :event
  mount_uploader :file, ImageUploader
end