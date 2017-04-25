# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Event < ActiveRecord::Base
  include MarkupScrubber
  include TagUtilities
  serialize :provided_presenter_order

  attr_accessor :presenter_tokens
  attr_accessor :tag_list
  attr_accessor :session_start_string
  attr_accessor :is_broadcast

  # define accessible attributes
  attr_accessible :creator, :last_modifier
  attr_accessible :title, :description, :session_length, :location, :recording, :primary_audience
  attr_accessible :presenter_tokens, :tag_list, :session_start_string, :time_zone, :is_expired, :is_canceled, :is_deleted, :reason_is_deleted
  attr_accessible :conference, :conference_id, :room, :event_type, :presenter_ids, :is_broadcast, :featured, :featured_at, :evaluation_link
  attr_accessible :material_links_attributes
  attr_accessible :images_attributes
  attr_accessible :cover_image, :remove_cover_image, :cover_image_cache
  attr_accessible :requires_registration, :registration_contact_id, :registration_description
  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :images, :allow_destroy => true

  # specify image uploader for carrierwave
  mount_uploader :cover_image, CoverImageUploader

  # revisioning
  has_paper_trail :on => [:update], :virtual => [:presenter_tokens, :tag_list]

  # types
  ONLINE = 'online'
  CONFERENCE = 'conference'
  BROADCAST = 'broadcast'

  # primary audience
  AUDIENCE_BLANK  = 0
  AUDIENCE_EXTENSION = 1
  AUDIENCE_OTHER     = 2
  AUDIENCE_PUBLIC    = 3

  AUDIENCE_LABELS = {
    AUDIENCE_BLANK   => 'Not Set',
    AUDIENCE_EXTENSION => 'Extension Professionals',
    AUDIENCE_OTHER     => 'Other Professionals',
    AUDIENCE_PUBLIC    => 'Public'
  }

  # relationships
  has_many :taggings, :as => :taggable, dependent: :destroy
  has_many :tags, :through => :taggings
  belongs_to :creator, :class_name => "Learner"
  belongs_to :registration_contact, :class_name => "Learner"
  belongs_to :last_modifier, :class_name => "Learner"
  has_many :questions, order: 'priority,created_at', dependent: :destroy
  has_many :answers, :through => :questions
  has_many :comments, dependent: :destroy
  has_many :ratings, :as => :rateable, :include => :learner, :conditions => "learners.is_blocked = false", dependent: :destroy
  has_many :event_connections, dependent: :destroy
  has_many :learners, through: :event_connections, uniq: true
  has_many :event_registrations
  has_many :presenter_connections, dependent: :destroy
  has_many :presenters, through: :presenter_connections, :source => :learner, :order => 'position'
  has_many :event_activities, dependent: :destroy
  has_many :notifications, :as => :notifiable, dependent: :destroy
  has_many :notification_exceptions
  has_many :material_links
  accepts_nested_attributes_for :material_links, :reject_if => :all_blank, :allow_destroy => true

  #counter column relations
  has_many :bookmarks, through: :event_connections, source: :event, conditions: "connectiontype = 3"
  has_many :attended, through: :event_connections, source: :event, conditions: "connectiontype = 4"
  has_many :watchers, through: :event_connections, source: :event, conditions: "connectiontype = 5"
  has_many :commentators, through: :comments, source: :learner, conditions: "learners.is_blocked = false", uniq: true

  # conference sessions
  belongs_to :conference

  validates :title, :presence => true
  validates :description, :presence => true
  validates :session_start, :presence => true
  validates :session_length, :presence => true
  validates :location, :presence => true
  validates_presence_of :registration_contact_id, :if => :validate_registration_contact?

  validates :recording, :allow_blank => true, :uri => true
  validates :evaluation_link, :allow_blank => true, :uri => true

  before_validation :set_session_start
  before_validation :set_location_if_conference

  before_update :schedule_recording_notification
  before_update :update_event_notifications
  before_update :set_featured_at

  before_save :set_session_end
  before_save :set_presenters_from_tokens
  before_save :set_tags_from_tag_list
  after_update :fix_presenter_ordering

  after_create :create_event_notifications

  DEFAULT_TIMEZONE = 'America/New_York'
  # page default for paginate
  paginates_per 15

  # sunspot/solr search
  searchable do
    time :session_start
    text :title, more_like_this: true
    text :description, more_like_this: true
    text :tag_list
    text :presenter_names
    boolean :is_canceled
    boolean :is_expired
    boolean :is_deleted
  end

  scope :bookmarked, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::BOOKMARK]
  scope :attended, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::ATTEND]
  scope :watched, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::WATCH]

  scope :active, conditions: {is_canceled: false, is_deleted: false}
  scope :not_expired, conditions: {is_expired: false}
  scope :featured, conditions: {featured: true}

  # expecting array of tag strings
  scope :tagged_with_all, lambda{|tag_list|
    joins(:tags).where("tags.name IN (#{tag_list.map{|t| "'#{Tag.normalizename(t)}'"}.join(',')})").group("events.id").having("COUNT(events.id) = #{tag_list.size}")
  }

  scope :this_week, lambda {
    weekday = Time.now.utc.strftime('%u').to_i
    # if saturday or sunday - do next week, else this week
    if(weekday >= 6)
      where('session_start > ?',(Time.zone.now + 7.days).beginning_of_week).where('session_start <= ?', (Time.zone.now + 7.days).end_of_week)
    else
      where('session_start > ?',Time.zone.now.beginning_of_week).where('session_start <= ?', Time.zone.now.end_of_week)
    end
  }

  scope :last_week, lambda {
    weekday = Time.now.utc.strftime('%u').to_i
    # if saturday or sunday - do this week, else last week
    if(weekday >= 6)
      where('session_start > ?',Time.zone.now.beginning_of_week).where('session_start <= ?', Time.zone.now.end_of_week)
    else
      where('session_start > ?',(Time.zone.now - 7.days).beginning_of_week).where('session_start <= ?', (Time.zone.now - 7.days).end_of_week)
    end
  }


  scope :recommendation_epoch, lambda {
    weekday = Time.now.utc.strftime('%u').to_i
    # if saturday or sunday - this+next, else last+this
    if(weekday >= 6)
      where('session_start > ?',Time.zone.now.beginning_of_week).where('session_start <= ?', (Time.zone.now + 7.days).end_of_week)
    else
      where('session_start > ?',(Time.zone.now - 7.days).beginning_of_week).where('session_start <= ?', Time.zone.now.end_of_week)
    end
  }

  scope :projected_epoch, lambda {
    # this+next
    where('session_start > ?',Time.zone.now.beginning_of_week).where('session_start <= ?', (Time.zone.now + 7.days).end_of_week)
  }

  scope :upcoming, lambda { |limit=3, offset=0| where('(session_start >= ?) OR (session_start <= ? AND session_end > ?)',Time.zone.now, Time.zone.now, Time.zone.now).order("session_start ASC").limit(limit).offset(offset) }
  scope :recent,   lambda { |limit=3| where('session_start < ?',Time.zone.now).order("session_start DESC").limit(limit) }
  # in_progress is not being used right now, but wanted to add it as a convenience if we ever need just in progress events
  scope :in_progress, lambda { |limit=3| where('session_start <= ? AND session_end > ?', Time.zone.now, Time.zone.now).order("session_start ASC").limit(limit) }

  scope :date_filtered, lambda { |start_date,end_date| where('DATE(session_start) >= ? AND DATE(session_start) <= ?', start_date, end_date) }

  scope :conference, where(event_type: CONFERENCE)
  scope :nonconference, where('event_type != ?',CONFERENCE)
  scope :broadcast, where('event_type = ?',BROADCAST)

  scope :by_date, lambda {|date| where('DATE(session_start) = ?',date)}

SESSION_START_CHANGED_NOTIFICATION_UPDATES = [Notification::EVENT_REMINDER_EMAIL, Notification::EVENT_REMINDER_SMS, Notification::EVENT_REGISTRATION_REMINDER_EMAIL]

  def validate_registration_contact?
    requires_registration == true
  end

  def connections_list
    self.learners.valid.order('event_connections.created_at')
  end

  def set_location_if_conference
    if(self.event_type == Event::CONFERENCE)
      self.location = 'Conference Session'
    end
  end

  def is_broadcast
    (self.event_type == Event::BROADCAST)
  end

  # should only be exposed in a conference context
  def is_broadcast=(broadcast_boolean)
    if(broadcast_boolean.to_i == 1)
      self.event_type = Event::BROADCAST
    else
      self.event_type = Event::CONFERENCE
    end
  end

  def primary_audience=(audience_code)
    if(audience_code.blank?)
      audience_code = AUDIENCE_BLANK
    end
    write_attribute(:primary_audience, audience_code)
  end

  def primary_audience_label
    AUDIENCE_LABELS[self.primary_audience]
  end

  def presenter_tokens
    if(@presenter_tokens.nil?)
      @presenter_tokens = self.presenter_connections.order(:position).pluck(:learner_id).join(',')
    end
    @presenter_tokens
  end

  def presenter_tokens=(provided_presenter_tokens)
    compare_token_array = []
    if(provided_presenter_tokens.blank?)
      previous_presenter_tokens = self.presenter_tokens
      @presenter_tokens = ""
      if(!previous_presenter_tokens.blank?)
        @changed_attributes['presenter_tokens'] = previous_presenter_tokens
      end
    else
      provided_presenter_tokens.split(',').each do |presenter_token|
        compare_token_array << presenter_token
      end
      previous_presenter_tokens = self.presenter_tokens
      presenter_token_array = previous_presenter_tokens.split(',')
      @presenter_tokens = provided_presenter_tokens
      self.provided_presenter_order = provided_presenter_tokens.split(',')
      if(!((compare_token_array | presenter_token_array) - (compare_token_array & presenter_token_array)).empty?)
        @changed_attributes['presenter_tokens'] = previous_presenter_tokens
      end
    end
  end

  def presenter_tokens_tokeninput
    if(!self.presenter_tokens.blank?)
       presenter_tokeninput = []
       self.presenter_tokens.split(',').each do |presenter_id|
         if(learner = Learner.where(id: presenter_id).first)
           presenter_tokeninput << {id: learner.id, name: learner.name}
         end
       end
       presenter_tokeninput
    else
      []
    end
  end

  def description=(description)
    write_attribute(:description, self.scrub_and_sanitize(description))
  end

  def location=(location)
    write_attribute(:location, self.scrub_and_sanitize(location))
  end

  def set_presenters_from_tokens
    if(!self.presenter_tokens.blank?)
      self.presenter_ids = self.presenter_tokens.split(',')
    else
      self.presenter_ids = nil
    end
  end

  def fix_presenter_ordering
    if(!self.provided_presenter_order.blank?)
      self.provided_presenter_order.each_with_index do |learner_id,index|
        if(pc = self.presenter_connections.where(learner_id: learner_id).first)
          pc.update_column(:position, index+1)
        end
      end
    end
  end

  def tag_list
    if(@tag_list.blank?)
      @tag_list = self.tags.map(&:name).join(Tag::JOINER)
    end
    @tag_list
  end

  def presenter_names
    self.presenters.map{|p| p.name}.join(' : ')
  end

  def tag_list=(provided_tag_list)
    # just compare raw strings
    compare_tag_array = []
    provided_tag_list.split(Tag::SPLITTER).each do |tag_name|
      compare_tag_array << Tag.normalizename(tag_name)
    end
    previous_tag_list = self.tag_list
    tag_list_array = previous_tag_list.split(Tag::SPLITTER)
    @tag_list = provided_tag_list
    if(!((compare_tag_array | tag_list_array) - (compare_tag_array & tag_list_array)).empty?)
      @changed_attributes['tag_list'] = previous_tag_list
    end
  end

  def set_tags_from_tag_list
    tags_to_set = []
    self.tag_list.split(Tag::SPLITTER).each do |tag_name|
      if (!tag_name.blank?)
        if(tag = Tag.find_or_create_by_normalizedname(tag_name))
          tags_to_set << tag
        end
      end
    end
    self.tags = tags_to_set.uniq
  end

  def session_start_string
    if(@session_start_string.blank?)
      time = self.session_start.blank? ? Time.zone.now : self.session_start.in_time_zone(self.time_zone)
      @session_start_string = time.strftime('%Y-%m-%d %I:%M %p')
    end
    @session_start_string
  end

  def set_session_start
    begin
      cur_tz = Time.zone
      Time.zone = self.time_zone
      self.session_start = Time.zone.parse(self.session_start_string)
      Time.zone = cur_tz
    rescue
      self.session_start = nil
      self.errors.add('session_start_string', 'Time specified is invalid.')
    end
  end

  # this is mostly for the mailer situation where
  # we aren't setting Time.zone for the web request
  def session_start_for_learner(learner)
    if(!self.is_conference_session? and learner.has_time_zone?)
      self.session_start.in_time_zone(learner.time_zone)
    else
      self.session_start.in_time_zone(self.time_zone)
    end
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

  def recording=(recording_url)
    if(recording_url.blank?)
      if(!self.recording.nil?)
        write_attribute(:recording,'')
      end
    else
      write_attribute(:recording,recording_url)
    end
  end

  # return a list of similar articles using sunspot
  def similar_events(count = 4)
    search_results = self.more_like_this do
      with(:is_canceled, false)
      with(:is_expired, false)
      paginate(:page => 1, :per_page => count)
      adjust_solr_params do |params|
        params[:fl] = 'id,score'
      end
    end
    return_results = {}
    search_results.each_hit_with_result do |hit,event|
      return_results[event] = hit.score
    end
    return_results
  end

  def concluded?
    if(!self.session_end.blank?)
      return (Time.now.utc > self.session_end)
    else
      return false
    end
  end

  def started?(offset = 15.minutes)
    if(!self.session_start.blank?)
      return (Time.now.utc > self.session_start - offset)
    else
      return false
    end
  end

  def in_progress?
    return (self.session_start <= Time.zone.now) && (self.session_end > Time.zone.now)
  end

  def has_recording?
    !recording.blank?
  end

  # calculate end of session time by adding session_length times 60 (session_length is in minutes) to session_start
  def set_session_end
    self.session_end = self.session_start + (self.session_length * 60)
  end

  # gets a random list of stock questions and creates associated questions from them
  #
  # @param [Hash] options options for the stock question creation
  # @option options [Integer] :creator - the Learner ID to attach as the creator
  # @option options [Integer] :max_count - the max count of random questions to retrieve and copy
  #
  # @return [Array] array of questions created
  def add_stock_questions(options = {})
    max_count = options[:max_count] || StockQuestion::DEFAULT_RANDOM_COUNT

    stock_question_list = StockQuestion.random_questions(max_count)
    stock_question_list.each do |sq|
      self.questions << Question.create_from_stock_question(sq)
    end
    self.questions
  end

  def attendees
    learners.where("event_connections.connectiontype = ? AND learners.is_blocked = false", EventConnection::ATTEND)
  end

  def watched
    learners.where("event_connections.connectiontype = ? AND learners.is_blocked = false", EventConnection::WATCH)
  end

  def bookmarked
    learners.where("event_connections.connectiontype = ? AND learners.is_blocked = false", EventConnection::BOOKMARK)
  end

  # when an event is created, up to 6 notifications need to be created.
  # 1 notification via email (180 minutes before)
  # conference sessions will go out 1 hour before
  # 4 via sms (60,45,30,15 minutes)
  # we'll leave conference sessions alone for now
  # 1 Potential Email if the event is scheduled for iowa state's connect system
  def create_event_notifications
    if(self.is_conference_session?)
      Notification.create(notifiable: self, notificationtype: Notification::EVENT_REMINDER_EMAIL, delivery_time: self.session_start - 1.hours, offset: 1.hours)
    else
      Notification.create(notifiable: self, notificationtype: Notification::EVENT_REMINDER_EMAIL, delivery_time: self.session_start - 3.hours, offset: 3.hours)
    end
    Notification.create(notifiable: self, notificationtype: Notification::EVENT_REMINDER_SMS, delivery_time: self.session_start - 60.minutes, offset: 60.minutes)
    Notification.create(notifiable: self, notificationtype: Notification::EVENT_REMINDER_SMS, delivery_time: self.session_start - 45.minutes, offset: 45.minutes)
    Notification.create(notifiable: self, notificationtype: Notification::EVENT_REMINDER_SMS, delivery_time: self.session_start - 30.minutes, offset: 30.minutes)
    Notification.create(notifiable: self, notificationtype: Notification::EVENT_REMINDER_SMS, delivery_time: self.session_start - 15.minutes, offset: 15.minutes)
    Notification.create(notifiable: self, notificationtype: Notification::INFORM_IASTATE, delivery_time: 1.minute.from_now) unless !self.is_connect_session?
    Notification.create(notifiable: self, notificationtype: Notification::EVENT_REGISTRATION_REMINDER_EMAIL, delivery_time: self.session_start - 24.hours, offset: 24.hours)
  end

  # when an event is updated, the notifications need to be rescheduled if the event session_start changes
  def update_event_notifications
    Notification.create(notifiable: self, notificationtype: Notification::EVENT_EDIT, delivery_time: 1.minute.from_now) unless self.last_modifier == self.creator
    if self.session_start_changed?
      self.notifications.each{|notification| notification.update_delivery_time(self.session_start) if SESSION_START_CHANGED_NOTIFICATION_UPDATES.include?(notification.notificationtype)}
    end
    if self.session_start_changed? || self.session_length_changed? || self.location_changed?
      Notification.create(notifiable: self, notificationtype: Notification::UPDATE_IASTATE, delivery_time: 1.minute.from_now) if self.is_connect_session?
      if self.location_changed?
        Notification.create(notifiable: self, notificationtype: Notification::EVENT_LOCATION_CHANGE, delivery_time: Notification::LOCATION_CHANGE_NOTIFICATION_INTERVAL.from_now) unless Notification.pending_location_change_notification?(self)
      else
        Notification.create(notifiable: self, notificationtype: Notification::EVENT_RESCHEDULED, delivery_time: Notification::RESCHEDULED_NOTIFICATION_INTERVAL.from_now) unless Notification.pending_rescheduled_notification?(self)
      end
    end
    if self.is_canceled_changed?
      if self.is_canceled?
        Notification.create(notifiable: self, notificationtype: Notification::CANCELED_IASTATE, delivery_time: 1.minute.from_now) if self.is_connect_session?
        Notification.create(notifiable: self, notificationtype: Notification::EVENT_CANCELED, delivery_time: 1.minute.from_now)
      else
        Notification.create(notifiable: self, notificationtype: Notification::UPDATE_IASTATE, delivery_time: 1.minute.from_now) if self.is_connect_session?
        Notification.create(notifiable: self, notificationtype: Notification::EVENT_RESCHEDULED, delivery_time: Notification::RESCHEDULED_NOTIFICATION_INTERVAL.from_now) unless Notification.pending_rescheduled_notification?(self)
      end
    end
    if self.is_deleted_changed?
      if self.is_deleted?
        Notification.create(notifiable: self, notificationtype: Notification::CANCELED_IASTATE, delivery_time: 1.minute.from_now) if self.is_connect_session?
        Notification.create(notifiable: self, notificationtype: Notification::EVENT_DELETED, delivery_time: 1.minute.from_now)
      else
        Notification.create(notifiable: self, notificationtype: Notification::UPDATE_IASTATE, delivery_time: 1.minute.from_now) if self.is_connect_session?
        Notification.create(notifiable: self, notificationtype: Notification::EVENT_RESCHEDULED, delivery_time: Notification::RESCHEDULED_NOTIFICATION_INTERVAL.from_now) unless Notification.pending_rescheduled_notification?(self)
      end
    end
  end

  def send_notifications?
    !self.is_deleted? and !self.is_canceled? and !self.is_expired?
  end

  def set_featured_at
    if self.featured_changed?
      if self.featured == true
        self.featured_at = Time.now
      else
        self.featured_at = nil
      end
    end
  end

  def content_for_atom_entry
    content = self.description + "\n\n"
    content << "Location: " + self.location + "\n\n" if !self.location.blank?
    content << "Session Start: " + self.session_start.in_time_zone(self.time_zone).xmlschema + "\n"
    content << "Session Length: " + self.session_length.to_s + " minutes\n"
    content << "Recording: " + self.recording if !self.recording.blank?
    content
  end

  def self.tagged_with(taglist)
    # split and collect - Tag.normalizename *should* take care of any nasty chars we don't want sent to the db
    normalizedlist = taglist.split(Tag::SPLITTER).collect{|tagname| Tag.normalizename(tagname)}
    Event.includes([:tags]).where("tags.name IN (#{normalizedlist.map{|tagname| "'#{tagname}'"}.join(',')})")
  end

  def self.tagged_with_id(taglist)
    # convert taglist to an array of ids
    taglist = taglist.chomp.split(',')
    #get tag name from each id
    normalizedlist = Tag.where(id: taglist).pluck :name
    Event.includes(:tags).where tags: { name: normalizedlist }
  end

  def potential_learners(options = {})
    learners = self.learners.all
    presenters = self.presenters.all
    min_score = options[:min_score] || Settings.minimum_recommendation_score
    remove_connectors = options[:remove_connectors].nil? ? true : options[:remove_connectors]
    limit_to_learners = options[:limit_to_learners]
    learner_list = {}
    mlt_list = self.similar_events
    max_mlt_score = 0
    mlt_list.each do |mlt_event,mlt_score|
      if(mlt_score > max_mlt_score)
        max_mlt_score = mlt_score
      end
      learner_scores = mlt_event.event_activities.learner_scores
      learner_scores.each do |learner,score|
        next if(learner.retired? or learner.is_blocked?)

        if(limit_to_learners)
          next if !limit_to_learners.include?(learner)
        end

        if(remove_connectors)
          next if learners.include?(learner)
          next if presenters.include?(learner)
        end

        if(learner_list[learner])
          learner_list[learner] += (score * mlt_score)
        else
          learner_list[learner] = (score * mlt_score)
        end
      end
    end

    learner_list.each do |learner,score|
      learner_list[learner] = learner_list[learner] / max_mlt_score
    end

    if(min_score)
      learner_list.delete_if{|learner,score| score < min_score}
    end

    learner_list
  end

  def self.potential_learners(options = {})
    with_scope do
      event_list = {}
      self.active.not_expired.all.each do |event|
        learners = {}
        with_exclusive_scope do
          learners =  event.potential_learners(options)
        end
        event_list[event] = learners
      end
      event_list
    end
  end

  def schedule_recording_notification
    if self.recording_changed? and !self.recording.blank?
      Notification.create(notifiable: self, notificationtype: Notification::RECORDING, delivery_time: 1.minute.from_now)
    end
  end

  def is_connect_session?
    self.location.match(Settings.iastate_connect_url).nil? ? false : true
  end

  def is_online_session?
    [ONLINE,BROADCAST].include?(self.event_type)
  end

  def is_conference_session?
    self.event_type != ONLINE
  end

  def evaluation_questions
    if(self.is_conference_session?)
      self.conference.evaluation_questions.order('questionorder')
    else
      []
    end
  end

  def zoom_webinar_id
    return nil if(self.location.blank?)
    begin
      url = URI.parse(self.location)
      return nil if (url.host != Settings.zoom_webinar_host)
      if(url.path =~ %r{/j/(\d+)})
        return $1
      else
        return nil
      end
    rescue
      return nil
    end
  end

  def set_zoom_webinar_uuid
    return false if(!self.concluded?)
    return false if(self.zoom_webinar_id.blank?)
    uuidlist = ZoomApi.get_zoom_webinar_uuid_list(self.zoom_webinar_id)
    return false if uuidlist.blank?
    founduuid = ''
    minimumtime = ''
    uuidlist.each do |occurrence|
      if(!occurrence["start_time"].blank? and !occurrence["uuid"].blank?)
        puts "Here!  #{occurrence} #{minimumtime} #{founduuid}"
        uuidtime = Time.parse(occurrence["start_time"])
        timebetween = (self.session_start - uuidtime).abs
        if(minimumtime.blank? or minimumtime >= timebetween)
          founduuid = occurrence["uuid"]
          minimumtime = timebetween
        end
      end
    end
    self.update_column(:zoom_webinar_uuid, founduuid) if !founduuid.blank?
  end

  #convenience method to reset counter columns
  def self.reset_counter_columns
    Event.find_each do |event|
      event.update_column(:bookmarks_count, event.bookmarks.count)
      event.update_column(:attended_count, event.attended.count)
      event.update_column(:watchers_count, event.watchers.count)
      event.update_column(:commentators_count, event.commentators.count)
    end
  end

  #convenience method verify column counts are correct
  def self.verify_column_counts
    inconsistencies = []
    Event.find_each do |event|
      if event.bookmarks_count != event.bookmarked.count
        inconsistencies << "Bookmarks inconsistancy found in Event #{event.id} (#{event.bookmarks_count} vs. #{event.bookmarked.count})"
      end

      if event.attended_count != event.attendees.count
        inconsistencies << "Attendees inconsistancy found in Event #{event.id} (#{event.attended_count}  vs. #{event.attendees.count})"
      end

      if event.watchers_count != event.watchers.count
        inconsistencies << "Watchers inconsistancy found in Event #{event.id} (#{event.watchers_count}  vs. #{event.watchers.count})"
      end

      if event.commentators_count != event.commentators.count
        inconsistencies << "Commentators inconsistancy found in Event #{event.id} (#{event.commentators_count} vs. #{event.commentators.count})"
      end
    end
    inconsistencies
  end

end
