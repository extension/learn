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

  end


  desc "reindex", "Reindex Learners that are flagged for updates"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  def reindex
    load_rails(options[:environment])
    Learner.reindex_learners_with_update_flag
  end

end

CronTasks.start
