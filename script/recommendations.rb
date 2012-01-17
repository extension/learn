#!/usr/bin/env ruby
require 'rubygems'
require 'thor'

class Recomaker < Thor
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
  
  desc "create", "Create a set of recommendations for the current recommendation epoch"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  def create
    load_rails(options[:environment])    
    Recommendation.create_from_epoch
  end
  
  desc "display", "Display the learners and their recommended event titles for the current recommendation epoch"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  method_option :min_score,:default => 3, :aliases => "-s", :desc => "Minimum connection score"
  method_option :remove_connectors,:default => true, :aliases => "-c", :desc => "Remove learners that already have a connection"
  def display
    load_rails(options[:environment])
    event_options = {}
    event_options[:min_score] = options[:min_score].to_i
    event_options[:remove_connectors] = options[:remove_connectors]
    learners_events = Learner.recommended_events(event_options)
    learners_events.each do |learner,eventlist|
      puts "#{learner.name} :"
      eventlist.each do |event|
        puts "  #{event.title}"
      end
    end    
  end
  
end

Recomaker.start