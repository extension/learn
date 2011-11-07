source 'http://systems.extension.org/rubygems/'
source 'http://rubygems.org'

gem 'rails', "3.1.1"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~> 3.1.4"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier', '>= 1.0.3'
end

# rails 3.1 default
gem 'jquery-rails'

# Deploy with Capistrano
gem 'capistrano'

# xml parsing
gem 'nokogiri'

# authentication
gem 'devise', "1.4.9"

# oauth integration
gem 'omniauth', '0.3.2'

# feed retrieval and parsing
gem "feedzirra", "0.0.31ex"

# storage
gem 'sqlite3'
gem 'mysql2'

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
gem "sunspot_rails", "~> 1.3.0.rc4" 

# faker for creating fake data
gem "faker"

# used to post-process mail to convert styles to inline
gem "csspool", "2.0.1ex"
gem "inline-style", "0.5.2ex"

# auto_link replacement
gem "rinku", :require => 'rails_rinku'

# require sunspot_solr for test and dev
group :test, :development do
  gem 'sunspot_solr', "~> 1.3.0.rc4" 
end

# delayed_job
gem "delayed_job"

# tropo - sms messages
gem "tropo-webapi-ruby"

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