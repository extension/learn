

#!/usr/bin/env ruby
require 'rubygems'
require 'thor'

class Importer < Thor
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

    def get_csv_data(csv_data_url)
      response = RestClient.get(csv_data_url)
      if(!response.code == 200)
        return nil
      end
      csvdata = response.to_str    
      # force utf8 - for some reason it's coming across as ASCII-8BIT
      csvdata.force_encoding('UTF-8')
      csvdata
    end

    # def get_nexc_data()
    #   get_csv_data('https://docs.google.com/spreadsheet/pub?key=0AiKHgDf9UwV6dEd4WW5fb2tpc0paV3h5bmJ2TkV2Mmc&single=true&gid=0&output=csv')
    # end
  end
  
  # desc "nexc_import", "Download and import the NeXC session data as events"
  # method_option :environment,:default => 'development', :aliases => "-e", :desc => "Rails environment"
  # def nexc_import
  #   load_rails(options[:environment])
  #   if(csv_data = get_nexc_data)
  #     if(conference = Conference.find_by_hashtag('nexc2012'))
  #       results = conference.import_sessions_from_csv_data(csv_data)
  #       puts "Imported #{results[:created_count]} events"
  #       if(results[:error_count] > 0)
  #         puts "Unable to import #{results[:error_count]} events, showing titles and errors"
  #         results[:error_titles].keys.each do |title|
  #           puts "  Title: #{title}"
  #           puts "  Errors: #{results[:error_titles][title]}"
  #         end
  #       end
  #     else
  #       puts "Unable to find nexc2012 conference"
  #     end
  #   else
  #     puts "Unable to download nexc2012 data"
  #   end
  # end
  
end

Importer.start