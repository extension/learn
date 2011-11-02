# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Learner < ActiveRecord::Base
  devise :rememberable, :trackable
  

  # Setup accessible (or protected) attributes
  attr_accessible :email, :remember_me, :name 
  
  has_many :ratings
  has_many :authmaps
  has_many :comments
  has_many :event_connections
  has_many :events, through: :event_connections, uniq: true
  
  DEFAULT_TIMEZONE = 'America/New_York'
  
  scope :presenters, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::PRESENTER]
  scope :attendees, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::ATTENDED]
  scope :interested, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::INTERESTED]
  scope :willattend, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::WILLATTEND]
  
  
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
  
  # since we return a default string from timezone, this routine
  # will allow us to check for a null/empty value so we can
  # prompt people to come set one.
  def has_time_zone?
    tzinfo_time_zone_string = read_attribute(:time_zone)
    return (!tzinfo_time_zone_string.blank?)
  end
  
  def self.learnbot
    find(self.learnbot_id)
  end
  
  def self.learnbot_id
    1
  end
  
  # placeholder for now
  def recommended_events(count = 4)
    Event.limit(count)
  end
end
