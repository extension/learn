# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class StockQuestion < ActiveRecord::Base
  serialize :responses
  belongs_to :learner
  
  validates :active, :presence => true
  validates :prompt, :presence => true
  validates :responsetype, :presence => true
  validates :responses, :presence => true
  validates :range_start, :numericality => { :only_integer => true, :allow_nil => true  }
  validates :range_end, :numericality => { :only_integer => true, :allow_nil => true  }
  validates :learner, :presence => true
  
  # types, strings in case we ever want to inherit from this model
  BOOLEAN = 'boolean'
  SCALE = 'scale'
  MULTIVOTE_BOOLEAN = 'multivote_boolean'
  
  scope :active, {:conditions => {:active => true}}
  scope :scale, {:conditions => {:responsetype => SCALE}}
  scope :notscale, {:conditions => ['responsetype != ?',SCALE]}
  scope :boolean, {:conditions => {:responsetype => BOOLEAN}}
  scope :multivote_boolean, {:conditions => {:responsetype => MULTIVOTE_BOOLEAN}}
  
  DEFAULT_RANDOM_COUNT = 3
  
  def self.random_questions(count = DEFAULT_RANDOM_COUNT)
     StockQuestion.active.shuffle.slice(0,count)
  end
    
end
