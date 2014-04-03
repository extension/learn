#!/usr/bin/env ruby
 
# Load Rails
if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"] == ""
  ENV["RAILS_ENV"] = 'production'
end
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

late_count = Delayed::Job.where("run_at < ?", Time.now).count

$stderr.puts "Check to see if delayed_job died. #{late_count} job(s) waiting to be sent. " if late_count > 0