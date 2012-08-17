# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Conference < ActiveRecord::Base
  attr_accessible :name, :hashtag, :tagline, :description, :website, :start_date, :end_date, :creator, :last_modifier, :creator_id, :last_modifier_id

  validates :name, :presence => true
  validates :hashtag, :uniqueness => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :website, :allow_blank => true, :uri => true

  has_many :conference_connections
  has_many :events
  belongs_to :creator, :class_name => "Learner"
  belongs_to :last_modifier, :class_name => "Learner"

  def self.find_by_id_or_hashtag(id)
    if(id =~ %r{[[:alpaha]]?})
      conference = self.find_by_hashtag(id)
    end

    if(!conference)
      conference = self.find_by_id(id)
    end

    if(!conference)
      raise ActiveRecord::RecordNotFound
    end

    conference
  end

end