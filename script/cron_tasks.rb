# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
require 'rubygems'
require 'thor'

class CronTasks < Thor
  include Thor::Actions

  # these are not the tasks that you seek
  no_tasks do
    # load rails based on environment

    def load_rails(environment)
      if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"] == ""
        ENV["RAILS_ENV"] = environment
      end
      require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
    end

    def clean_up_mailer_caches
      MailerCache.delete_all(["created_at < ?", 3.months.ago])
      puts "Cleaned up Mailer Caches more than 3 months old"
    end

    def clean_up_notifications
      Notification.delete_all(["delivery_time < ?", 3.months.ago])
      puts "Cleaned up Notifications delivered more than 3 months ago"
    end

    def clean_up_recommendations
      Recommendation.destroy_all(["created_at < ?", 3.months.ago])
      puts "Cleaned up Notifications delivered more than 3 months ago"
    end

  end

  desc "hourly", "Run hourly tasks"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  def hourly
    load_rails(options[:environment])
    Learner.reindex_learners_with_update_flag
  end

  desc "daily", "Run daily tasks"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  def daily
    load_rails(options[:environment])
    Event.daily_webinar_events_update
    clean_up_mailer_caches
    clean_up_notifications
    clean_up_recommendations
  end

end

CronTasks.start
