# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class StockQuestion < ActiveRecord::Base
  serialize :responses
  belongs_to :creator, :class_name => 'Learner'
  
  validates :active, :presence => true
  validates :prompt, :presence => true
  validates :responsetype, :presence => true
  validates :responses, :presence => true
  validates :range_start, :numericality => { :only_integer => true, :allow_nil => true  }
  validates :range_end, :numericality => { :only_integer => true, :allow_nil => true  }
  validates :creator, :presence => true
  
  # types, strings in case we ever want to inherit from this model
  BOOLEAN = 'boolean'
  SCALE = 'scale'
  MULTIVOTE_BOOLEAN = 'multivote_boolean'
  
  scope :active, {:conditions => {:active => true}}
  
  DEFAULT_RANDOM_COUNT = 3
  
  def self.random_questions(count = DEFAULT_QUESTION_COUNT)
    # we can get away with loading all of them to shuffle
    # because there aren't going to be many stock questions
    # in the database
    StockQuestion.active.shuffle.slice(0,count)
  end
    
end
