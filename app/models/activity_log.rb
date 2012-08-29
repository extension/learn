# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
require 'ipaddr'

class ActivityLog < ActiveRecord::Base
  serialize :additional
  belongs_to :learner
  belongs_to :loggable, polymorphic: true
  validates :learner, :presence => true
  validates :loggable, :presence => true
  
  scope :event_activity_records, conditions: {'loggable_type' => 'EventActivity'}
  scope :learner_activity_records, conditions: {'loggable_type' => 'LearnerActivity'} 
   
  def self.log_email_open(mailer_cache,additional_information)
    self.create(learner: mailer_cache.learner, loggable: mailer_cache, additional: additional_information)
  end
  
  
end
