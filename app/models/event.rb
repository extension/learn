# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Event < ActiveRecord::Base
  include MarkupScrubber
  
  attr_accessor :presenter_tokens
  attr_accessor :tag_list
  attr_accessor :session_start_string
  has_many :taggings, :as => :taggable, dependent: :destroy
  has_many :tags, :through => :taggings
  belongs_to :creator, :class_name => "Learner"
  belongs_to :last_modifier, :class_name => "Learner"
  has_many :questions, order: 'priority,created_at', dependent: :destroy
  has_many :answers, :through => :questions
  has_many :comments, dependent: :destroy
  has_many :ratings, :as => :rateable, dependent: :destroy
  has_many :raters, :through => :ratings, :source => :learner
  has_many :event_connections, dependent: :destroy
  has_many :learners, through: :event_connections, uniq: true
  has_many :presenter_connections, dependent: :destroy
  has_many :presenters, through: :presenter_connections, :source => :learner
  has_many :event_activities, dependent: :destroy
  has_many :notifications, :as => :notifiable, dependent: :destroy
  has_many :notification_exceptions


  validates :title, :presence => true
  validates :description, :presence => true
  validates :session_start, :presence => true
  validates :session_length, :presence => true
  validates :location, :presence => true
  
  validates :recording, :allow_blank => true, :uri => true
  
  before_save :set_session_end
  before_save :set_presenters_from_tokens
  before_save :set_tags_from_tag_list
  
  after_create :create_event_notifications
  after_update :update_event_notifications
  
  DEFAULT_TIMEZONE = 'America/New_York'
  # page default for will_paginate
  self.per_page = 15
  
  # sunspot/solr search
  searchable do
    time :session_start
    text :title, more_like_this: true
    text :description, more_like_this: true
  end
  
  scope :bookmarked, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::BOOKMARK]
  scope :attended, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::ATTEND]
  scope :watched, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::WATCH]
  
  scope :through_this_week, lambda { where('session_end >= ?',Time.zone.now).where('session_end <= ?', (Time.zone.now + 7.days).end_of_week) }
  scope :upcoming, lambda { |limit=3| where('session_start >= ?',Time.zone.now).order("session_start ASC").limit(limit) }
  scope :recent,   lambda { |limit=3| where('session_start < ?',Time.zone.now).order("session_start DESC").limit(limit) }
  
  def presenter_tokens
    if(@presenter_tokens.blank?)
      @presenter_tokens = self.presenter_ids.join(',')
    end
    @presenter_tokens
  end
    
  def presenter_tokens_tokeninput
    if(!self.presenter_tokens.blank?)
      presenter_list = Learner.where("id IN (#{self.presenter_tokens})").all
      presenter_list.collect{|presenter| {id: presenter.id, name: presenter.name}}
    else
      {}
    end
  end
  
  def description=(description)
    write_attribute(:description, self.scrub_and_sanitize(description))
  end
    
  def set_presenters_from_tokens
    self.presenter_ids = self.presenter_tokens.split(',')
  end
    
  def tag_list
    if(@tag_list.blank?)
      @tag_list = self.tags.map(&:name).join(Tag::JOINER)
    end
    @tag_list
  end
  
  def set_tags_from_tag_list
    tags_to_set = []
    self.tag_list.split(Tag::SPLITTER).each do |tag_name|
      if(tag = Tag.find_or_create_by_normalizedname(tag_name))
        tags_to_set << tag
      end
    end
    self.tags = tags_to_set
  end
  
  def session_start_string
    time = self.session_start.blank? ? Time.zone.now : self.session_start.in_time_zone(self.time_zone)
    time.strftime('%Y-%m-%d %I:%M pm')
  end
  
  def session_start_string=(datetime_string)
    begin
      self.session_start = Time.zone.parse(datetime_string)
    rescue
      self.session_start = nil
      self.errors.add('session_start_string', 'Time specified is invalid.')
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
  
  
  # return a list of similar articles using sunspot
  def similar_events(count = 4)
    search_results = self.more_like_this do
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
  
  
  def similar_events_through_next_week(count = 4)
    search_results = self.more_like_this do
      paginate(:page => 1, :per_page => count)
      adjust_solr_params do |params|
        params[:fl] = 'id,score'
      end
      with(:session_start).between(Time.zone.now..(Time.zone.now + 7.days).end_of_week)
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
    learner_id = (options[:learner].nil?) ? Learner.learnbot_id : options[:learner].id 
    max_count = options[:max_count] || StockQuestion::DEFAULT_RANDOM_COUNT
    
    stock_question_list = StockQuestion.random_questions(max_count)
    stock_question_list.each do |sq|
      attributes = {learner_id: learner_id}
      ['prompt','responsetype','responses','range_start','range_end'].each do |attribute|
        attributes[attribute] = sq.send(attribute)
      end
      self.questions << Question.create(attributes)
    end
    self.questions
  end
    
  def attendees
    learners.where("event_connections.connectiontype = ?", EventConnection::ATTEND)
  end
  
  def bookmarked
    learners.where("event_connections.connectiontype = ?", EventConnection::BOOKMARK)
  end
  
  # when an event is created, 5 notifications need to be created.
  # 1 notification via email (180 minutes before)
  # 4 via sms (60,45,30,15 minutes)
  def create_event_notifications
    Notification.create(:notifiable => self, :notificationtype => Notification::EVENT_REMINDER_EMAIL, :delivery_time => self.session_start - 3.hours, :offset => 3.hours)
    Notification.create(:notifiable => self, :notificationtype => Notification::EVENT_REMINDER_SMS, :delivery_time => self.session_start - 60.minutes, :offset => 60.minutes)
    Notification.create(:notifiable => self, :notificationtype => Notification::EVENT_REMINDER_SMS, :delivery_time => self.session_start - 45.minutes, :offset => 45.minutes)
    Notification.create(:notifiable => self, :notificationtype => Notification::EVENT_REMINDER_SMS, :delivery_time => self.session_start - 30.minutes, :offset => 30.minutes)
    Notification.create(:notifiable => self, :notificationtype => Notification::EVENT_REMINDER_SMS, :delivery_time => self.session_start - 15.minutes, :offset => 15.minutes)
  end
  
  # when an event is updated, the notifications need to be rescheduled if the event session_start changes
  def update_event_notifications
    self.notifications.each{|notification| notification.update_delivery_time(self.session_start)}
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

end
