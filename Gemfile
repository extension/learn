source 'http://rubygems.org'
source 'http://systems.extension.org/rubygems/'

gem 'rails', "3.2.5"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~> 3.2.4"
  gem 'coffee-rails', "~> 3.2.2"
  gem 'uglifier', '>= 1.0.3'
end

# rails 3.1 default
gem 'jquery-rails', "1.0.16"

# bootstrap in sass in rails
gem 'anjlab-bootstrap-rails', :require => 'bootstrap-rails'

# storage
gem 'mysql2'

# image upload
gem 'carrierwave'

# image processing
gem 'rmagick'

# Deploy with Capistrano
gem 'capistrano'
gem 'capatross'

# xml parsing
gem 'nokogiri'

# authentication
gem 'devise', "~> 1.5.1"
gem 'omniauth-facebook'
gem 'omniauth-openid'
gem 'omniauth-twitter'

# oauth integration
gem 'omniauth', "~> 1.0"

# feed retrieval and parsing
# force curb to 0.7.15 to avoid a constant warning
gem "curb", "0.7.15"
gem "feedzirra", "0.1.2"

# pagination
gem 'will_paginate'

# server settings
gem "rails_config"

# exception notification
gem "airbrake"

#phusion passenger
gem 'passenger'

# comment and threaded discussion support
gem 'ancestry'

# readability port
gem "ruby-readability", "~> 0.2.4" ,:require => 'readability'

# html scrubbing
gem "loofah"

# htmlentities conversion
gem "htmlentities"

# search on solr
gem "sunspot_rails", "~> 1.3.0" 

# used to post-process mail to convert styles to inline
gem "csspool", "2.0.1ex"
gem "inline-style", "0.5.2ex"

# auto_link replacement
gem "rinku", :require => 'rails_rinku'

# require sunspot_solr for test and dev
group :test, :development do
  gem 'sunspot_solr', "~> 1.3.0" 
end

#god
gem "god", :require => false

# delayed_job
gem "delayed_job"
gem 'delayed_job_active_record'
gem "daemons"

# tropo - sms messages
gem "tropo-webapi-ruby"

# command line scripts 
gem "thor"

# revisioning
#gem "paper_trail", :git => 'git://github.com/extension/paper_trail.git'
gem "paper_trail", "2.5.2ex"

group :development do
  # require the powder gem
  gem 'powder'
  # rails3 compatible generators
  gem "rails3-generators"

end
 
group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'shoulda', '>= 3.0.0.beta'
  gem 'factory_girl_rails'
  gem 'mocha'
end