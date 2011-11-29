# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Event < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  attr_accessor :presenter_tokens
  attr_accessor :tag_list
  attr_accessor :session_start_string
  
  attr_accessor :rev_tags
  
  # define accessible attributes
  attr_accessible :title, :description, :session_length, :location, :recording, :presenter_tokens, :tag_list, :session_start_string
  
  # revisioning
  has_paper_trail :virtual => [:rev_presenters, :rev_tags]
  
  # relationships
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
  

  validates :title, :presence => true
  validates :description, :presence => true
  validates :session_start, :presence => true
  validates :session_length, :presence => true
  validates :location, :presence => true
  
  validates :recording, :allow_blank => true, :uri => true
  
  before_save :set_session_end
  
  DEFAULT_TIMEZONE = 'America/New_York'
  
  # sunspot/solr search
  searchable do
    text :title, more_like_this: true
    text :description, more_like_this: true
  end
  
  scope :bookmarked, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::BOOKMARK]
  scope :attended, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::ATTEND]
  scope :watched, include: :event_connections, conditions: ["event_connections.connectiontype = ?", EventConnection::WATCH]
  
  scope :through_next_week, conditions: ["session_end >= ? and session_end <= ?", Time.zone.now, (Time.zone.now + 7.days).end_of_week] 
  
  def presenter_tokens=(idlist)
    self.presenter_ids = idlist.split(',')
  end
  
  def rev_presenters
    self.presenter_ids
  end
  memoize :rev_presenters
  
  def rev_tags
    self.tag_ids
  end
  
  def rev_presenters=(presenter_id_array)
    @rev_presenters = presenter_id_array
  end
  
  def rev_tags=(tag_id_array)
    @rev_tags = tag_id_array
  end
  
  def presenters_to_tokenhash
    self.presenters.collect{|presenter| {id: presenter.id, name: presenter.name}}
  end
  
  def tag_list
    self.tags.map(&:name).join(Tag::JOINER)
  end
  
  def tag_list=(tag_list)
    @tag_list = tag_list
    tags_to_set = []
    tag_list.split(Tag::JOINER).each do |tag_name|
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
    search_results.results
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
    
end
