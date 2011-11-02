# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Event < ActiveRecord::Base
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings
  belongs_to :creator, :class_name => "Learner", :foreign_key => "created_by"
  belongs_to :last_modifier, :class_name => "Learner", :foreign_key => "last_modified_by"
  has_many :questions, :order => 'priority,created_at'
  has_many :answers, :through => :questions
  has_many :comments
  has_many :ratings, :as => :rateable
  has_many :raters, :through => :ratings, :source => :learner
  has_many :event_connections
  has_many :learners, through: :event_connections, uniq: true
  
  
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
    creator_id = (options[:creator].nil?) ? Learner.learnbot_id : options[:creator].id 
    max_count = options[:max_count] || StockQuestion::DEFAULT_RANDOM_COUNT
    
    stock_question_list = StockQuestion.random_questions(max_count)
    stock_question_list.each do |sq|
      attributes = {creator_id: creator_id}
      ['prompt','responsetype','responses','range_start','range_end'].each do |attribute|
        attributes[attribute] = sq.send(attribute)
      end
      self.questions << Question.create(attributes)
    end
    self.questions
  end
  
end
