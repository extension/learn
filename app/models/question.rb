# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Question < ActiveRecord::Base
  serialize :responses
  belongs_to :event
  belongs_to :creator, :class_name => 'Learner'
  has_many :answers
  
  validates :prompt, :presence => true
  validates :responsetype, :presence => true
  validates :responses, :presence => true
  validates :range_start, :numericality => { :only_integer => true, :allow_nil => true }
  validates :range_end, :numericality => { :only_integer => true, :allow_nil => true  }
  validates :priority, :numericality => { :only_integer => true, :allow_nil => true  }
  validates :event, :presence => true
  validates :creator, :presence => true
  
  # types, strings in case we ever want to inherit from this model
  BOOLEAN = 'boolean'
  SCALE = 'scale'
  MULTIVOTE_BOOLEAN = 'multivote_boolean'
  
  
  def answer_for_creator_and_response(options = {})
    creator = options[:creator]
    response = options[:response]
    scoped =  self.answers.where(creator_id: creator.id)
    if(!response.nil?)
      scoped = scoped.where(response: response)
    end
    scoped.first
  end
  
  def answer_value_for_creator_and_response(options = {})
    if(answer = self.answer_for_creator_and_response(options))
      answer.value
    else
      nil
    end
  end
  
  # creates or updates the answer or answers associated with this question based on the value or values provided
  #
  # @param [Hash] options options for finding/creating the answer
  # @option options [Learner]  :creator - the Learner object to attach as the creator
  # @option options :update_value - the Integer value or Array values (depending on the question type)
  #
  def create_or_update_answers(options = {})
    creator = options[:creator]
    update_value = options[:update_value]
    
    case self.responsetype
    when Question::BOOLEAN
      if(answer = self.answers.where(creator_id: creator.id).first)
        answer.update_attributes({response: self.responses[update_value.to_i], value: update_value})
      else
        answer = self.answers.create(creator: creator, response: self.responses[update_value.to_i], value: update_value)
      end  
    when Question::SCALE
      if(answer = self.answers.where(creator_id: creator.id).first)
        answer.update_attribute(:value,update_value)
      else
        answer = self.answers.create(creator: creator, value: update_value)
      end  
    when Question::MULTIVOTE_BOOLEAN
      answers = []
      if(update_value.blank?)
        self.answers.where(creator_id: creator.id).destroy_all
      else
        self.responses.each do |response|
          if(update_value.include?(response))
            if(!(answer = self.answers.where(creator_id: creator.id).where(response: response).first))
              answer = self.answers.create(creator: creator, value: 1, response: response)
            end
            answers << answer
          else
            if(answer = self.answers.where(creator_id: creator.id).where(response: response).first)
              answer.destroy
            end
          end
        end
      end  
    end
    self.answers
  end
  
  
  # returns the answer data associated with the responses for the given question
  #
  def answer_data
    returndata = []
    case self.responsetype
    when Question::BOOLEAN
      response_counts = self.answers.group('response').count
      self.responses.each do |response|
        returndata << [response,response_counts[response] || 0]
      end
    when Question::SCALE
      response_counts = self.answers.group('value').count
      self.range_start.upto(self.range_end) do |value|
        returndata << [value,response_counts[value] || 0]
      end
    when Question::MULTIVOTE_BOOLEAN
      response_counts = self.answers.group('response').count
      self.responses.each do |response|
        returndata << [response,response_counts[response] || 0]
      end
    end
    return returndata
  end
  
  

end
