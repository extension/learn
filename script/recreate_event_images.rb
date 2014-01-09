#!/usr/bin/env ruby
 
# Load Rails
if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"] == ""
  ENV["RAILS_ENV"] = 'production'
end
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

Event.all.each do |event|
  if event.images.size > 0
    event.images.each do |image|
      if File.exists?(Rails.root.join("public#{image.file_url()}"))
        image.file.recreate_versions!
      end
    end
  end
end