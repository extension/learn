# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EvaluationQuestion < ActiveRecord::Base
  serialize :responses
  belongs_to :conference
  belongs_to :creator, :class_name => "Learner"
  attr_accessible :conference, :conference_id, :creator, :creator_id, :prompt, :secondary_prompt, :responses, :responsetype, :range_start, :range_end, :questionorder
  has_many :evaluation_answers

  # validates :prompt, :presence => true
  # validates :responsetype, :presence => true
  # validates :responses, :presence => true
  # validates :learner, :presence => true
  
  # types, strings in case we ever want to inherit from this model
  MULTIPLE_CHOICE = 'multiple_choice'
  COMPOUND_MULTIPLE_OPEN = 'compound_multiple_open'
  

  def answer_for_learner_and_event(learner,event)
    self.evaluation_answers.where(learner_id: learner.id).where(event_id: event.id).first
  end

  def answer_counts_for_event(event)
    self.evaluation_answers.where(event_id: event.id).group(:response).count
  end



  def answer_total_for_event(event)
    self.evaluation_answers.where(event_id: event.id).count
  end

  def answer_counts
    self.evaluation_answers.group(:response).count
  end
  
  def answer_total
    self.evaluation_answers.count
  end

  def response_value(response)
    if(self.responselist.include?(response))
      self.responselist.index(response) + 1
    else
      0
    end
  end

  def is_trigger_response?(response)
    if(self.responsetype != COMPOUND_MULTIPLE_OPEN)
      false
    else
      self.responses[:triggers].include?(response)
    end
  end

  def responselist
    if(self.responsetype == COMPOUND_MULTIPLE_OPEN)
      self.responses[:responsestrings]
    else
      self.responses
    end
  end

  def open_responses_for_event(event)
    if(self.responsetype != COMPOUND_MULTIPLE_OPEN)
      []
    else
      self.evaluation_answers.where(event_id: event.id).where("secondary_response IS NOT NULL").pluck(:secondary_response)
    end
  end

  def open_responses
    if(self.responsetype != COMPOUND_MULTIPLE_OPEN)
      []
    else
      self.evaluation_answers.where("secondary_response IS NOT NULL").pluck(:secondary_response)
    end
  end

  def create_or_update_answers(options = {})
    learner = options[:learner]
    event = options[:event]
    params = options[:params]
    
    case self.responsetype
    when MULTIPLE_CHOICE
      if(answer = self.answer_for_learner_and_event(learner,event))
        answer.update_attributes({response: params[:response], value: self.response_value(params[:response])})
      else
        answer = self.evaluation_answers.create(learner: learner, event: event, response: params[:response], value: self.response_value(params[:response]))
      end
      answer
    when COMPOUND_MULTIPLE_OPEN
      save_attributes = {response: params[:response], value: self.response_value(params[:response])}
      if(self.is_trigger_response?(params[:response]))
        save_attributes[:secondary_response] = params[:secondary_response]
      end

      if(answer = self.answer_for_learner_and_event(learner,event))
        answer.update_attributes(save_attributes)
      else
        save_attributes.merge!({learner: learner, event: event})
        answer = self.evaluation_answers.create(save_attributes)
      end
    else
      # nothing
    end
  end
    
end
