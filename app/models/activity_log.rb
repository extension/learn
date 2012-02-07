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
  
  def self.log_email_open(mailer_cache,additional_information)
    self.create(learner: mailer_cache.learner, loggable: mailer_cache, additional: additional_information)
  end
  
  
end
