# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomApi


  def self.get_zoom_webinar_attendee_list(webinar_id, options = {})
    request_options = options.merge({id: webinar_id})
    get_zoom_paged_attribute('attendees','webinar/attendees/list',request_options)
  end

  def self.get_zoom_webinar_registration_list(webinar_id, options = {})
    request_options = options.merge({id: webinar_id})
    get_zoom_paged_attribute('attendees','webinar/registration',request_options)
  end

  # makes a paged request - logging and returning the requested combined array
  def self.get_zoom_paged_attribute(attribute,endpoint,options = {})
    attribute_array = []
    request_options = options.dup
    if(response = make_single_zoom_request(endpoint,request_options))
      attribute_array += response[attribute]
      # additional requests
      if(response["page_count"] and response["page_count"] > 1)
        page_count = response["page_count"]
        get_next_page = 2
        success_request = true
        while(get_next_page <= page_count and success_request)
          request_options = request_options.merge({:page_number => get_next_page})
          if(response = make_single_zoom_request(endpoint,request_options))
            attribute_array += response[attribute]
            get_next_page += 1
          else
            success_request = false
          end
        end
      end
    else
      return nil
    end
    attribute_array
  end

  def self.make_single_zoom_request(endpoint, options = {})
    # for logging
    if(options[:request_id])
      request_id = options.delete(:request_id)
    end

    endpoint = endpoint[1..-1] if(endpoint[0] == '/') # side effects I know
    api_endpoint = "https://api.zoom.us/v1/#{endpoint}"
    baseparams = {
      api_key: Settings.zoom_api_key,
      api_secret: Settings.zoom_api_secret,
      host_id: Settings.zoom_webinar_id
    }

    requestparams = baseparams.merge(options)

    begin
      response = RestClient.post(api_endpoint,requestparams)
    rescue=> e
      response = e.response
    end

    # log it
    ZoomApiLog.create(:request_id => request_id,
                      :response_code => response.code,
                      :endpoint => endpoint,
                      :requestparams => requestparams,
                      :additionaldata => response)


    if(!response.code == 200)
      return nil
    else
      begin
        parsed_response = JSON.parse(response)
        return parsed_response
      rescue
        return nil
      end
    end

  end

end
