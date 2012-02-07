# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventActivity < ActiveRecord::Base
  belongs_to :learner
  belongs_to :event
  belongs_to :trackable, polymorphic: true
  has_many :activity_logs, :as => :loggable, dependent: :destroy
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
  CONNECT_BOOKMARK          = 52
  CONNECT_ATTEND            = 53
  CONNECT_WATCH             = 54
  
  # scoring
  SCORING = {
    VIEW                      => 0,
    VIEW_FROM_RECOMMENDATION  => 2,
    VIEW_FROM_SHARE           => 2,
    SHARE                     => 1,
    ANSWER                    => 1,
    RATING                    => 1,
    RATING_ON_COMMENT         => 1,
    COMMENT                   => 2,
    COMMENT_ON_COMMENT        => 2,
    CONNECT                   => 3,
    CONNECT_PRESENTER         => 3,
    CONNECT_BOOKMARK          => 3,
    CONNECT_ATTEND            => 3,
    CONNECT_WATCH             => 3,
  }
  
  ACTIVITY_MAP = {
    1   => "viewed",
    2   => "viewed from a reccomendation",
    3   => "viewed from a share",
    11  => "shared",
    21  => "answered a question",
    31  => "rated an event",
    32  => "rated a comment",
    41  => "commented",
    42  => "commented on a comment",
    50  => "connected",
    51  => "connected as presenter",
    52  => "bookmarked",
    53  => "attended",
    54  => "watched",    
  }
  
  HISTORY_ITEMS = [ANSWER,RATING,RATING_ON_COMMENT,COMMENT,COMMENT_ON_COMMENT,CONNECT,CONNECT_PRESENTER,CONNECT_BOOKMARK,CONNECT_ATTEND,CONNECT_WATCH]
  
  
  # don't recommend making this a callback, instead
  # intentionally call it where appropriate (like EventActivity.create_or_update)
  def create_activity_log(additional_information)
    self.activity_logs.create(learner: self.learner, additional: additional_information)
  end
  
  def description
    ACTIVITY_MAP[self.activity]
  end
  
  def self.description_for_id(id_number)
    ACTIVITY_MAP[id_number]
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
    when 'PresenterConnection'
      self.log_presenter(object)
    else
      nil
    end
  end
      
  def self.log_view(learner,event,source = nil)
    case source
    when 'recommendation'
      activity = VIEW_FROM_RECOMMENDATION
    when 'share'
      activity = VIEW_FROM_SHARE
    else
      activity = VIEW
    end
    self.create_or_update(learner: learner, event: event, activity: activity, trackable: event)
  end
  
  def self.log_share
  end

  def self.log_answer(answer)
    self.create_or_update({learner: answer.learner, event: answer.event, activity: ANSWER, trackable: answer.question}, {answer: answer.id})
  end
  
  def self.log_rating(rating)
    if(rating.rateable.is_a?(Comment))
      activity = RATING_ON_COMMENT
      event = rating.rateable.event
      self.create(learner: rating.learner, event: event, activity: activity, trackable: rating)
    elsif(rating.rateable.is_a?(Event))
      activity = RATING
      event = rating.rateable
      self.create_or_update({learner: rating.learner, event: event, activity: activity, trackable: rating} )
    else
      nil
    end
  end
  
  def self.log_comment(comment)
    if(comment.is_reply?)
      activity = COMMENT_ON_COMMENT
    else
      activity = COMMENT
    end
    self.create_or_update({learner: comment.learner, event: comment.event, activity: activity, trackable: comment})
  end
  
  def self.log_connection(event_connection)
    case(event_connection.connectiontype)
    when EventConnection::BOOKMARK
      activity = CONNECT_BOOKMARK
    when EventConnection::ATTEND
      activity = CONNECT_ATTEND
    when EventConnection::WATCH
      activity = CONNECT_WATCH
    else
      activity = CONNECT
    end
    self.create_or_update({learner: event_connection.learner, event: event_connection.event, activity: activity, trackable: event_connection})
  end
  
  def self.log_presenter(presenter_connection)
    self.create_or_update({learner: presenter_connection.learner, event: presenter_connection.event, activity: CONNECT_PRESENTER, trackable: presenter_connection})
  end

  def self.find_by_unique_key(attributes)
    scoped = self.where(learner_id: attributes[:learner].id)
    scoped = scoped.where(event_id: attributes[:event].id)
    scoped = scoped.where(activity: attributes[:activity])
    scoped = scoped.where(trackable_type: attributes[:trackable].class.name)
    scoped = scoped.where(trackable_id: attributes[:trackable].id)    
    scoped.first
  end
  
  def self.create_or_update(attributes,additional_information = nil)
    begin 
      record = self.create(attributes)
    rescue ActiveRecord::RecordNotUnique => e
      record = self.find_by_unique_key(attributes)
      record.increment!(:activity_count)
    end
    record.create_activity_log(additional_information)  
  end
  
  def self.learner_scores
    id_scores= {}
    learner_scores = {}
    with_scope do
      activity_counts = group(:learner_id).group(:activity).count
      activity_counts.each do |(learner_id,activity), count|
        id_scores[learner_id] = id_scores[learner_id] ? id_scores[learner_id] + SCORING[activity] : SCORING[activity]
      end
    end
    id_scores.each do |learner_id,score|
      learner_scores[Learner.find_by_id(learner_id)] = score.to_f
    end
    learner_scores
  end
end
