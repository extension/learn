# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class EventTest < ActiveSupport::TestCase

  context "Creating a new event" do
    should validate_presence_of(:title)
    should validate_presence_of(:description)
    should validate_presence_of(:session_start)
    should validate_presence_of(:session_length)
    should validate_presence_of(:location)
          
    # URL validation
    VALID_URLS   = ['http://dogs.icanhascheezburger.com/', 'https://dogs.icanhascheezburger.com/', 'http://dogs.icanhascheezburger.com/2011/02/01/funny-dog-pictures-whos-awesome-youre-awesome/', 
                    'http://www.newscientist.com/feed/view;jsessionid=942442D4AD329735FC229CDE354C8AA6?id=online-news' ]

    INVALID_URLS = ['ftp://dogs.icanhascheezburger.com/', 'dogs.icanhascheezburger.com', 'http:/dogs.icanhascheezburger.com', 'http:/dogs.icanhascheezburger.com/2011/02/01/funny-dog-pictures-whos-awesome-youre-awesome/',
                    'mailto:test@testdomain.com']

  
    VALID_URLS.each do |url|
      should allow_value(url).for(:recording)
    end
  
    INVALID_URLS.each do |url|
      should_not allow_value(url).for(:recording)
    end
  end
  
end
