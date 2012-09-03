# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EvaluationQuestion < ActiveRecord::Base
  serialize :responses
  belongs_to :conference
  belongs_to :creator, :class_name => "Learner"
  attr_accessible :conference, :conference_id, :creator, :creator_id, :prompt, :secondary_prompt, :responses, :responsetype, :range_start, :range_end, :order

  # validates :active, :presence => true
  # validates :prompt, :presence => true
  # validates :responsetype, :presence => true
  # validates :responses, :presence => true
  # validates :range_start, :numericality => { :only_integer => true, :allow_nil => true  }
  # validates :range_end, :numericality => { :only_integer => true, :allow_nil => true  }
  # validates :learner, :presence => true
  
  # types, strings in case we ever want to inherit from this model
  BOOLEAN = 'boolean'
  SCALE = 'scale'
  MULTIVOTE_BOOLEAN = 'multivote_boolean'
  MULTIPLE_CHOICE = 'multiple_choice'
  OPEN_ANSWER = 'open_answer'
  COMPOUND_MULTIPLE_OPEN = 'compound_multiple_open'
  
    
end
