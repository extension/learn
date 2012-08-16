# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Conference < ActiveRecord::Base
  attr_accessible :name, :hashtag, :tagline, :description, :website, :start_date, :end_date

  validates :name, :presence => true
  validates :hashtag, :uniqueness => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :website, :allow_blank => true, :uri => true

  has_many :conference_connections
  has_many :events

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