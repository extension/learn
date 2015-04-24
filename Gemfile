source 'http://rubygems.org'
source 'https://engineering.extension.org/rubygems'

gem 'rails', "4.2.1"

gem 'jquery-rails', "~> 2.3.0"

# Gems used only for assets and not required
# in production environments by default.
# speed up sppppppprooooockets
#gem 'turbo-sprockets-rails3' <-- removed for rails 4
gem 'turbolinks'
#group :assets do <--- removed for rails 4 update
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'outfielding-jqplot-rails'
#end

# bootstrap in sass in rails
gem 'bootstrap-sass', '~> 3.1.1.1'

# replaces glyphicons
gem 'font-awesome-rails'

# storage
gem 'mysql2'

# xml parsing
gem 'nokogiri'

# image upload
gem 'carrierwave'

# image processing
gem 'rmagick'

# Deploy with Capistrano
gem 'capistrano'
gem 'capatross'

# authentication
gem 'devise'
gem 'omniauth-facebook'
gem 'omniauth-openid'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'

# oauth integration
gem 'omniauth', "~> 1.0"

# pagination
gem 'kaminari'

# nested forms
gem "cocoon"

# server settings
gem "rails_config"

# exception notification
gem 'honeybadger'

# comment and threaded discussion support
gem 'ancestry'

# diffs
gem 'diffy'


# html scrubbing
gem "loofah"

# htmlentities conversion
gem "htmlentities"

# search on solr
gem "sunspot_rails"

# used to post-process mail to convert styles to inline
gem "csspool"
gem "inline-style", "0.5.2ex"

# auto_link replacement
gem "rinku", :require => 'rails_rinku'

# http retrieval
gem 'rest-client'

# wysihtml5 + bootstrap + asset pipeline
gem 'bootstrap-wysihtml5-rails'

# require sunspot_solr for test and dev
group :test, :development do
  gem 'sunspot_solr'
end

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
#gem "paper_trail", "2.5.2ex" <--removed for rails 4
gem 'paper_trail', '~> 4.0.0.beta' #add for rails 4

# terse logging
gem 'lograge'

#add order of presenters to events
gem 'acts_as_list'

group :development do
  # require the powder gem
  gem 'powder'
  # rails3 compatible generators
  gem "rails3-generators"
  gem 'pry'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'net-http-spy'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'shoulda', '>= 3.0.0.beta'
  gem 'factory_girl_rails'
  gem 'mocha'
end

#rails4 gems
gem 'protected_attributes' # https://github.com/rails/protected_attributes
gem 'activeresource' # https://github.com/rails/activeresource
gem 'actionpack-action_caching' # https://github.com/rails/actionpack-action_caching
gem 'activerecord-session_store' # https://github.com/rails/activerecord-session_store
gem 'rails-observers' # https://github.com/rails/rails-observers
