# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Learner < ActiveRecord::Base

  # Setup accessible (or protected) attributes
  attr_accessible :email, :remember_me, :name, :avatar, :bio, :mobile_number, :remove_avatar, :avatar_cache, :needs_search_update

  # specify image uploader for carrierwave
  mount_uploader :avatar, AvatarUploader

  has_many :activity_logs, dependent: :destroy
  has_many :created_events, :class_name => "Event", :foreign_key => 'creator_id'
  has_many :modified_events, :class_name => "Event", :foreign_key => 'last_modifier_id'
  has_many :event_connections, dependent: :destroy
  has_many :events, through: :event_connections, uniq: true
  has_many :zoom_connections, dependent: :destroy
  has_many :zoom_webinars, through: :zoom_connections, uniq: true
  has_many :event_activities, dependent: :destroy
  has_many :presenter_connections, dependent: :destroy
  has_many :presented_events, through: :presenter_connections, source: :event
  has_many :preferences, :as => :prefable, dependent: :destroy
  has_many :notification_exceptions, dependent: :destroy
  has_many :recommendations, dependent: :destroy
  has_many :mailer_caches, :as => :cacheable, :class_name => "MailerCache", dependent: :destroy
  has_one  :portfolio_setting, dependent: :destroy

  before_validation :convert_mobile_number
  validates_length_of :mobile_number, :is => 10, :allow_blank => true
  validates_length_of :bio, :maximum => 140

  DEFAULT_TIMEZONE = 'America/New_York'

  # elasticsearch
  if(Settings.elasticsearch_enabled)
    update_index('learners#learner') { self }
  end

  scope :needs_search_update, lambda{ where(needs_search_update: true)}
  scope :active, ->{where(retired: false)}
  scope :extension, ->{where("darmok_id IS NOT NULL")}
  scope :non_extension, ->{where("darmok_id IS NULL")}

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

  def is_extension_account?
    return self.darmok_id.present?
  end

  # this instance method used to merge two learner accounts into one account, particularly used
  # when merging two accounts created for the same learner resulting from a learner using
  # more than one method of authentication (eg. twitter, eXtension, etc.)
  def merge_account_with(learner_id,forceself = false)
    learner_to_merge = Learner.find_by_id(learner_id)
    # we're keeping the first learner account created and merging the later one with it
    # along with destroying the later account when the merging is complete
    if(learner_to_merge.created_at >= self.created_at or forceself or !self.darmok_id.blank?)
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

        begin
          model_to_use.where("#{key_of_learner} = #{learner_to_remove.id}" + "#{additional_conditions}").update_all(key_of_learner.to_sym => learner_to_keep.id)
        rescue ActiveRecord::RecordNotUnique
          # don't worry about it
        end
      when :has_and_belongs_to_many
        join_table = association_to_learner.options[:join_table]
        if !association_to_learner.options[:foreign_key].blank?
          key_of_learner = association_to_learner.options[:foreign_key]
        else
          key_of_learner = 'learner'
        end
        # do raw sql here to update a join table without having to instantiate the objects and do AR (delete old and add new) operations
        # that triggers callbacks.
        connection.execute("UPDATE IGNORE #{join_table} SET #{key_of_learner} = #{learner_to_keep.id} WHERE #{key_of_learner} = #{learner_to_remove.id}")
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

  def connected_to_event?(event)
    !self.events.where('event_id = ?',event.id).first.nil?
  end

  def is_presenter_for_event?(event)
    !self.presented_events.where('event_id = ?',event.id).first.nil?
  end

  def is_following_event?(event)
    !self.followed_events.where('event_id = ?',event.id).first.nil?
  end

  def attended_event?(event)
    !self.attended_events.where('event_id = ?',event.id).first.nil?
  end

  def viewed_event?(event)
    !self.viewed_events.where('event_id = ?',event.id).first.nil?
  end

  def has_event_notification_exception?(event)
    !self.notification_exceptions.where('event_id = ?',event.id).first.nil?
  end

  def has_connection_with_event?(event)
    !self.events.where('event_id = ?',event.id).first.nil?
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

  # convenience methods for consistent use between presented_events and recommended_events that
  # help with the conditionals of the learner's connection with the event
  def attended_events
    events.active.where("event_connections.connectiontype = ?", EventConnection::ATTEND)
  end

  def viewed_events
    events.active.where("event_connections.connectiontype = ?", EventConnection::VIEW)
  end

  def followed_events
    events.active.where("event_connections.connectiontype = ?", EventConnection::FOLLOW)
  end

  # this is relatively inefficient - because all learner scores for the event scope chosen
  # will end up being calculated, but it's easier to take advantage of what's already there
  # the output could be cached if needed.
  def recommended_events(options = {})
    events = {}
    modified_options = options.dup
    modified_options[:limit_to_learners] = [self]
    show_zeros = modified_options.delete(:show_zeros) || false
    max_events = modified_options.delete(:max_events) || Settings.recommended_events
    event_scope = modified_options.delete(:event_scope) || 'recommendation_epoch'

    if(event_scope == 'all')
      event_list = Event.active.not_expired.potential_learners(modified_options)
    else
      event_list = Event.active.not_expired.send(event_scope).potential_learners(modified_options)
    end
    event_list.each do |event,learner_list|
      if(show_zeros and learner_list.blank?)
        events[event] = 0.0
      else
        if(!learner_list.blank?)
          learner_list.each do |learner,score|
            if(learner == self)
              events[event] = score
            end
          end
        end
      end
    end
    events
  end


  def self.recommended_events(options = {})
    learners = {}
    return_learners = {}
    modified_options = options.dup
    max_events = modified_options.delete(:max_events) || Settings.recommended_events
    event_scope = modified_options.delete(:event_scope) || 'recommendation_epoch'

    if(event_scope == 'all')
      event_list = Event.active.not_expired.potential_learners(modified_options)
    else
      event_list = Event.active.not_expired.send(event_scope).potential_learners(modified_options)
    end

    event_list.each do |event,learner_list|
      learner_list.each do |learner,score|
        if(learners[learner])
          learners[learner] << {:event => event, :score => score}
        else
          learners[learner] = [{:event => event, :score => score}]
        end
      end
    end

    learners.each do |learner,score_events|
      return_learners[learner] = score_events.sort{|hash1,hash2| hash1[:score] <=> hash2[:score]}.map{|h| h[:event]}.slice(0,max_events)
    end
    return_learners
  end

  def send_notifications?(event)
    !self.email.blank? and self.send_reminder? and !self.has_event_notification_exception?(event)
  end

  def send_recommendation?
    self.preferences.setting('notification.recommendation')
  end

  def send_reminder?
    self.preferences.setting('notification.reminder.email')
  end

  def send_sms?(notice)
    self.preferences.setting('notification.reminder.sms') and (self.preferences.setting('notification.reminder.sms.notice').to_f == notice)
  end

  def send_activity?
    self.preferences.setting('notification.activity')
  end

  def send_rescheduled_or_canceled?
    self.preferences.setting('notification.rescheduled_or_canceled')
  end

  def send_location_change?
    self.preferences.setting('notification.location_changed')
  end

  def send_recording?
    self.preferences.setting('notification.recording')
  end

  def public_presented_events?
    self.preferences.setting('sharing.events.presented')
  end

  def public_attended_events?
    self.preferences.setting('sharing.events.attended')
  end

  def public_viewed_events?
    self.preferences.setting('sharing.events.viewed')
  end

  def public_followed_events?
    self.preferences.setting('sharing.events.followed')
  end

  def public_portfolio?
    self.preferences.setting('sharing.portfolio')
  end

  def send_recommendation=(send_it)
    Preference.create_or_update(self,'notification.recommendation',send_it)
  end

  def is_private_for_event_types?(event_types)
    event_types.each do |event_type|
      if(!self.preferences.setting("sharing.events.#{event_type}"))
        return true
      end
    end
    return false
  end

  def self.reindex_learners_with_update_flag
    self.needs_search_update.all.each do |learner|
      # merely updating the account should trigger reindexing
      learner.update_attributes({needs_search_update: false})
    end
  end

  def first_name
    name.split(' ')[0]
  end

  def last_name
    name.split(' ')[1]
  end

  def self.fix_duplicate_extension_accounts
    multi_accounts = Learner.group(:darmok_id).having("count(id) > 1").count
    multi_accounts.each do |darmok_id,count|
      next if(count <= 1)
      next if(darmok_id.nil?)
      # get first account
      if(learner = Learner.where(darmok_id: darmok_id).first)
        # get id's
        ids = Learner.where(darmok_id: darmok_id).where("id != ?",learner.id).pluck(:id)
        ids.each do |id|
          learner.merge_account_with(id,true)
        end
      end
    end
  end

  def self.fix_duplicate_email_accounts
    multi_accounts = Learner.group(:email).having("count(id) > 1").count
    multi_accounts.each do |email,count|
      next if(count <= 1)
      next if(email.blank?)
      # get first account - bias toward darmok_id
      learner = Learner.where(email: email).where("darmok_id is not NULL").first
      if(!learner)
        learner = Learner.where(email: email).first
      end
      if(learner)
        # get id's
        ids = Learner.where(email: email).where("id != ?",learner.id).pluck(:id)
        ids.each do |id|
          learner.merge_account_with(id,true)
        end
      end
    end
  end

  def signin_allowed?
    !self.retired?
  end

  def self.find_by_openid(uid_string)
    if !uid_string.blank? and learner = Learner.where({:openid => uid_string}).first
      learner
    else
      nil
    end
  end

  def is_mfln_registration_contact?
    Settings.mfln_registration_contacts.include?(self.id)
  end

end
