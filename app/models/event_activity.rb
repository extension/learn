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
  CONNECT                   = 50
  CONNECT_FOLLOW            = 52
  CONNECT_ATTEND            = 53
  CONNECT_VIEW             = 54

  # scoring
  SCORING = {
    CONNECT                   => 3,
    CONNECT_FOLLOW            => 3,
    CONNECT_ATTEND            => 3,
    CONNECT_VIEW             => 3,
  }

  ACTIVITY_MAP = {
    CONNECT  => "connected",
    CONNECT_FOLLOW  => "followed",
    CONNECT_ATTEND  => "attended",
    CONNECT_VIEW  => "viewed"
  }

  HISTORY_ITEMS = [CONNECT,CONNECT_FOLLOW,CONNECT_ATTEND,CONNECT_VIEW]

  scope :views, where(activity: 1)

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
    when 'EventConnection'
      self.log_connection(object)
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
    when EventConnection::FOLLOW
      activity = CONNECT_FOLLOW
    when EventConnection::ATTEND
      activity = CONNECT_ATTEND
    when EventConnection::VIEW
      activity = CONNECT_VIEW
    else
      activity = CONNECT
    end
    self.create_or_update({learner: event_connection.learner, event: event_connection.event, activity: activity, trackable: event_connection})
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
    valid_activities = SCORING.keys
    with_scope do
      activity_counts = group(:learner_id).where("activity IN (#{valid_activities.join(',')})").group(:activity).count
      activity_counts.each do |(learner_id,activity), count|
        id_scores[learner_id] = id_scores[learner_id] ? id_scores[learner_id] + SCORING[activity] : SCORING[activity]
      end
    end
    id_scores.each do |learner_id,score|
      learner = Learner.find_by_id(learner_id)
      if(!learner.nil?)
        learner_scores[learner] = score.to_f
      end
    end
    learner_scores
  end
end
