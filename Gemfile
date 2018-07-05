source 'http://rubygems.org'
gem 'rails', "3.2.22.5"

# rails 3.1 default
gem 'jquery-rails'

# Gems used only for assets and not required
# in production environments by default.
# speed up sppppppprooooockets
gem 'turbo-sprockets-rails3'
group :assets do
  gem 'sass-rails', "~> 3.2.4"
  gem 'coffee-rails', "~> 3.2.2"
  gem 'uglifier', '>= 1.0.3'

  gem 'outfielding-jqplot-rails'
end

# bootstrap in sass in rails
gem 'bootstrap-sass', '~> 3.1.1.1'

# replaces glyphicons
gem 'font-awesome-rails'

# storage
gem 'mysql2'

# xml parsing
gem 'nokogiri'

# image upload
gem 'carrierwave', :source => 'http://rubygems.org/'

# image processing
gem 'rmagick'

# authentication
gem 'omniauth-openid'

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

# diffs
gem 'diffy'

#email validation
gem 'valid_email'

# html scrubbing
gem "loofah"

# htmlentities conversion
gem "htmlentities"

# to enable Google Tag Manager
gem 'rack-tracker', "1.1.0ex", :source => 'https://engineering.extension.org/rubygems'

# elasticsearch
gem 'chewy'

# rake progress
gem "progress_bar"

# used to post-process mail to convert styles to inline
gem "csspool"
gem "inline-style", "0.5.2ex", :source => 'https://engineering.extension.org/rubygems/'

# auto_link replacement
gem "rinku", :require => 'rails_rinku'

# wysihtml5 + bootstrap + asset pipeline
gem 'bootstrap-wysihtml5-rails'

# delayed_job
gem "delayed_job"
gem 'delayed_job_active_record'
gem "daemons"

# tropo - sms messages
gem "tropo-webapi-ruby"

# command line scripts
gem "thor"

# revisioning
gem "paper_trail", "2.5.2ex", :source => 'https://engineering.extension.org/rubygems'

# terse logging
gem 'lograge'

#add order of presenters to events
gem 'acts_as_list'

# Ruby 2.2 requirement
gem 'test-unit'

# zoom api work
gem 'rest-client'

# text cleanup
gem "auto_strip_attributes", "~> 2.0"

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capatross', :source => 'https://engineering.extension.org/rubygems'
  # require the powder gem
  gem 'powder'
  # require puma for those switching to puma
  gem 'puma'
  # rails3 compatible generators
  gem "rails3-generators"
  gem 'pry'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'httplog'
end
