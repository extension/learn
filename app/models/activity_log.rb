# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
require 'ipaddr'

class ActivityLog < ActiveRecord::Base
  belongs_to :learner
  belongs_to :event
  belongs_to :loggable, :polymorphic => true
  validates :learner, :presence => true
  
  # types of activities - gaps are between types
  # in case we may need to group/expand
  VIEW                      = 1
  VIEW_FROM_RECOMMENDATION  = 2
  VIEW_FROM_SHARE           = 3
  SHARE                     = 11
  ANSWER                    = 21
  RATING                    = 31
  RATING_ON_COMMENT         = 32
  COMMENT                   = 41
  COMMENT_ON_COMMENT        = 42
  CONNECT                   = 50
  CONNECT_PRESENTER         = 51
  CONNECT_INTEREST          = 52
  CONNECT_WILLATTEND        = 53
  CONNECT_ATTEND            = 54
  CONNECT_WATCH             = 55
  
  # set up class variable that can be set in application.rb
  @request_ipaddr = '127.0.0.1'
  class << self
    attr_accessor :request_ipaddr
  end
  
  before_save :set_ipaddr_from_request_ip
  
  def ipaddr
    int_ip = read_attribute(:ipaddr)
    i = IPAddr.new(int_ip,Socket::AF_INET)
    i.to_s
  end
  
  def ipaddr=(value)
    i = IPAddr.new(value,Socket::AF_INET)
    write_attribute(:ipaddr,i.to_i)
  end
  
  def set_ipaddr_from_request_ip
    self.ipaddr = self.class.request_ipaddr
  end
  
  
  def self.log_object_activity(object)
    case object.class.name
    when 'Answer'
      self.log_answer(object)
    when 'Rating'
      self.log_rating(object)
    when 'Comment'
      self.log_comment(object)
    when 'EventConnection'
      self.log_connection(object)
    else
      nil
    end
  end
      
  def self.log_view
  end
  
  def self.log_share
  end

  def self.log_answer(answer)
    self.create(learner_id: answer.learner_id, event: answer.event, activity: ANSWER, loggable: answer)
  end
  
  def self.log_rating(rating)
    if(rating.rateable.is_a?(Comment))
      activity = RATING_ON_COMMENT
      event = rating.rateable.event
      self.create(learner_id: rating.learner_id, event: event, activity: activity, loggable: rating)
    elsif(rating.rateable.is_a?(Event))
      activity = RATING
      event = rating.rateable
      self.create(learner_id: rating.learner_id, event: event, activity: activity, loggable: rating )
    else
      nil
    end
  end
  
  def self.log_comment(comment)
    if(!comment.is_root?)
      activity = COMMENT_ON_COMMENT
    else
      activity = COMMENT
    end
    self.create(learner_id: comment.learner_id, event: comment.event, activity: activity, loggable: comment)
  end
  
  def self.log_connection(event_connection)
    case(event_connection.connectiontype)
    when EventConnection::PRESENTER
      activity = CONNECT_PRESENTER
    when EventConnection::INTERESTED
      activity = CONNECT_INTEREST
    when EventConnection::ATTENDED
      activity = CONNECT_ATTEND
    when EventConnection::WILLATTEND
      activity = CONNECT_WILLATTEND
    when EventConnection::WATCH
      activity = CONNECT_WATCH
    else
      activity = CONNECT
    end
    self.create(learner_id: event_connection.learner_id, event_id: event_connection.event_id, activity: activity, loggable: event_connection)
  end
  
      
end
