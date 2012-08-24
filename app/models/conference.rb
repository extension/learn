# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Conference < ActiveRecord::Base
  attr_accessible :name, :hashtag, :tagline, :description, :website, :start_date, :end_date, :creator, :last_modifier, :creator_id, :last_modifier_id, :time_zone

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
    # does the id contain a least one alpha? let's search by hashtag
    if(id =~ %r{[[:alpha:]]?})
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

  def in_progress?
    return (self.start_date <= Date.today) && (self.end_date >= Date.today)
  end

  def concluded?
    return !(self.end_date < Date.today)
  end


    # override timezone writer/reader
  # returns Eastern by default, use convert=false
  # when you need a timezone string that mysql can handle
  def time_zone(convert=true)
    tzinfo_time_zone_string = read_attribute(:time_zone)
    if(tzinfo_time_zone_string.blank?)
      tzinfo_time_zone_string = DEFAULT_TIMEZONE
    end

    if(convert)
      reverse_mappings = ActiveSupport::TimeZone::MAPPING.invert
      if(reverse_mappings[tzinfo_time_zone_string])
        reverse_mappings[tzinfo_time_zone_string]
      else
        nil
      end
    else
      tzinfo_time_zone_string
    end
  end

  def time_zone=(time_zone_string)
    mappings = ActiveSupport::TimeZone::MAPPING
    if(mappings[time_zone_string])
      write_attribute(:time_zone, mappings[time_zone_string])
    else
      write_attribute(:time_zone, nil)
    end
  end
  
end