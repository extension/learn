# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

# inspiration for this comes from https://github.com/collectiveidea/sunspot_test/blob/master/lib/sunspot_test.rb
# this adds a Sunspot.solr_running? method to ping the configured url from session.config
module Sunspot
  class << self
    def solr_running?
      begin
        solr_ping_uri = URI.parse("#{self.config.solr.url}/admin/ping")
        Net::HTTP.get(solr_ping_uri)
        true # Solr Running
      rescue
        false # Solr Not Running
      end
    end
  end
end