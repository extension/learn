# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Learner < ActiveRecord::Base
  devise :rememberable, :trackable, :database_authenticatable
  
  # Setup accessible (or protected) attributes
  attr_accessible :email, :remember_me, :name 
  
  has_many :ratings
  has_many :authmaps
  has_many :comments
  has_many :event_connections
  has_many :events, through: :event_connections, uniq: true
  has_many :event_activities
  has_many :presenter_connections
  has_many :presented_events, through: :presenter_connections, source: :event
  has_many :preferences, :as => :prefable
  
  DEFAULT_TIMEZONE = 'America/New_York'
  
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
  
  # override name to make sure to print something
  def name
    name_string = read_attribute(:name)
    name_string.blank? ? 'Learner' : name_string
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
  
  # devise override
  def active_for_authentication?
    super && !retired?
  end
  
  def has_bookmark_for_event?(event)
    find_event = self.events.bookmarked.where('event_id = ?',event.id)
    !find_event.blank?
  end
  
  def attended_event?(event)
    find_event = self.events.attended.where('event_id = ?',event.id)
    !find_event.blank?
  end
  
  def watched_event?(event)
    find_event = self.events.watched.where('event_id = ?',event.id)
    !find_event.blank?
  end
  
  def has_connection_with_event?(event)
    find_event = self.events.where('event_id = ?',event.id)
    !find_event.blank?
  end
    
  def connect_with_event(event,connectiontype)
    self.event_connections.create(event: event, connectiontype: connectiontype)
  end
  
  def remove_connection_with_event(event,connectiontype)
    if(connection = EventConnection.where('learner_id =?',self.id).where('event_id = ?',event.id).where('connectiontype = ?',connectiontype).first)
      connection.destroy
    end
  end 
   
end
