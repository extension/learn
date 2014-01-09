#!/usr/bin/env ruby
 
# Load Rails
ENV['RAILS_ENV'] = ARGV[0] || 'production'
DIR = File.dirname(__FILE__) 
require DIR + '/../config/environment'

Event.all.each do |event|
  if event.images.size > 0
    event.images.each do |image|
      if File.exists?(Rails.root.join("public#{image.file_url()}"))
        image.file.recreate_versions!
      end
    end
  end
end