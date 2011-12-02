# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Learner < ActiveRecord::Base
  devise :rememberable, :trackable, :database_authenticatable
  
  # Setup accessible (or protected) attributes
  attr_accessible :email, :remember_me, :name 
  
  has_many :ratings, :as => :rateable
  has_many :authmaps
  has_many :comments
  has_many :event_connections
  has_many :events, through: :event_connections, uniq: true
  has_many :event_activities
  has_many :presented_events, through: :presenter_connections, source: :event
  has_many :preferences, :as => :prefable
  has_many :notification_exceptions
  
  before_validation :convert_mobile_number
  validates_length_of :mobile_number, :is => 10, :allow_blank => true
  
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
  
  # this instance method used to merge two learner accounts into one account, particularly used 
  # when merging two accounts created for the same learner resulting from a learner using 
  # more than one method of authentication (eg. twitter, eXtension, etc.)
  def merge_account_with(learner_id)
    learner_to_merge = Learner.find_by_id(learner_id)
    # we're keeping the first learner account created and merging the later one with it 
    # along with destroying the later account when the merging is complete
    if learner_to_merge.created_at > self.created_at 
      learner_to_keep = self
      learner_to_remove = learner_to_merge
    else
      learner_to_keep = learner_to_merge
      learner_to_remove = self
    end
    
    Learner.reflect_on_all_associations.each do |association_to_learner|
      # make sure we have the field we need to use for learner for the associated tables
      if !association_to_learner.options[:foreign_key].blank?
        key_of_learner = association_to_learner.options[:foreign_key]
      else
        key_of_learner = nil
      end
      
      additional_conditions = ''
      
      case association_to_learner.macro 
      when :has_many || :has_one
        # in the case of :has_one, I think it's pretty rare to see the :through and :as options get used,  
        # but I'm going to cover it along with :has_many anyways
        
        # operate on the 'through' table if it's has_many :through
        if !association_to_learner.options[:through].blank?
          model_to_use = association_to_learner.options[:through].to_s.singularize.camelize.constantize
          key_of_learner = "learner_id" if key_of_learner.blank?
        # the association name in the associated table will be different if we have options[:as] (polymorphic association)
        # and we'll need to update all records with options[:as]_id in the associated table
        elsif !association_to_learner.options[:as].blank?
          # get the class name of the associated table and the learner key (eg. prefable_id)
          key_of_learner = "#{association_to_learner.options[:as]}_id"
          model_to_use = association_to_learner.klass
          # need to get the type on a polymorphic association (eg. prefable_type)
          additional_conditions = " AND #{association_to_learner.options[:as]}_type = 'Learner'"
        else
          # the code below also works for the :class_name option b/c klass is pulling the target model
          key_of_learner = "learner_id" if key_of_learner.blank?
          model_to_use = association_to_learner.klass
        end
        
        model_to_use.where("#{key_of_learner} = #{learner_to_remove.id}" + "#{additional_conditions}").update_all(key_of_learner.to_sym => learner_to_keep.id)
      when :has_and_belongs_to_many
        join_table = association_to_learner.options[:join_table]
        if !association_to_learner.options[:foreign_key].blank?
          key_of_learner = association_to_learner.options[:foreign_key]
        else
          key_of_learner = 'learner'
        end
        # do raw sql here to update a join table without having to instantiate the objects and do AR (delete old and add new) operations 
        # that triggers callbacks.
        connection.execute("UPDATE #{join_table} SET #{key_of_learner} = #{learner_to_keep.id} WHERE #{key_of_learner} = #{learner_to_remove.id}")
      end
    end
    
    # if the learner record from eXtension authentication is the learner record to be removed, 
    # then transfer the darmok_id to the remaining learner account b/c that's needed for sync with darmok.
    if !learner_to_remove.darmok_id.blank?
      Learner.where("id = #{learner_to_keep.id}").update_all(:darmok_id => learner_to_remove.darmok_id)
    end
    
    learner_to_remove.destroy
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
  
  def has_event_notification_exception?(event)
    find_notification_exception = self.notification_exceptions.where('event_id = ?',event.id)
    !find_notification_exception.blank?
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
  
  #get the mobile number down to just the digits
  def convert_mobile_number
    self.mobile_number = self.mobile_number.to_s.gsub(/[^0-9]/, '') if self.mobile_number
  end 
   
end
