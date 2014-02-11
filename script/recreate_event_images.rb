#!/usr/bin/env ruby
 
# Load Rails
if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"] == ""
  ENV["RAILS_ENV"] = 'production'
end
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

Event.all.each do |event|
  if event.images.size > 0
    puts "working on event ##{event.id}"
    event.images.each do |image|
      if File.exists?(Rails.root.join("public#{image.file_url()}"))
      	puts "  recreating image versions for image ##{image.id}"
        image.file.recreate_versions!
      end
    end
  end
end