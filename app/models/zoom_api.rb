# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomApi

  def self.get_zoom_webinar(webinar_id, options={})
    request_options = options.merge({id: webinar_id})
    make_single_zoom_request('webinar/get',webinar_id,request_options)
  end

  def self.get_zoom_webinar_uuid_list(webinar_id, options={})
    request_options = options.merge({id: webinar_id})
    get_zoom_paged_attribute('webinars','webinar/uuid/list',webinar_id,request_options)
  end

  def self.get_zoom_webinar_panelists(webinar_id, options={})
    request_options = options.merge({id: webinar_id})
    get_zoom_paged_attribute('panelists','webinar/panelists',webinar_id,request_options)
  end

  def self.get_zoom_webinar_registration_list(webinar_id, options = {})
    request_options = options.merge({id: webinar_id})
    get_zoom_paged_attribute('attendees','webinar/registration',webinar_id,request_options)
  end

  def self.get_zoom_webinar_attendee_list(webinar_id, webinar_uuid, options = {})
    request_options = options.merge({uuid: webinar_uuid, id: webinar_id})
    get_zoom_paged_attribute('attendees','webinar/attendees/list',webinar_id,request_options)
  end

  # makes a paged request - logging and returning the requested combined array
  def self.get_zoom_paged_attribute(attribute,endpoint,webinar_id,options = {})
    attribute_array = []
    request_options = options.dup

    # pull out the request_id if we have one - so we can track down api calls
    if(request_options[:request_id])
      request_id = request_options.delete(:request_id)
    end

    if(response = make_single_zoom_request(endpoint,request_id,request_options))
      attribute_array += response[attribute]
      # additional requests
      if(response["page_count"] and response["page_count"] > 1)
        page_count = response["page_count"]
        get_next_page = 2
        success_request = true
        while(get_next_page <= page_count and success_request)
          request_options = request_options.merge({:page_number => get_next_page})
          if(response = make_single_zoom_request(endpoint,request_id,request_options))
            attribute_array += response[attribute]
            get_next_page += 1
          else
            return nil
            success_request = false
          end
        end
      end
    else
      return nil
    end
    attribute_array
  end

  def self.make_single_zoom_request(endpoint, webinar_id, options = {})
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
      response_error = false
      # parse
      begin
        parsed_response = JSON.parse(response)
        json_error = false
        if(parsed_response["error"])
          zoom_error = true
          zoom_error_code = parsed_response["error"]["code"]
          zoom_error_message = parsed_response["error"]["message"]
        end
      rescue
        json_error = true
      end
    rescue=> e
      response_error = true
      response = e.response
    end

    begin
      parsed_response = JSON.parse(response)
      json_error = false
    rescue
      json_error = true
    end

    # log it
    ZoomApiLog.create(:webinar_id => webinar_id,
                      :response_code => response.code,
                      :endpoint => endpoint,
                      :json_error => json_error,
                      :zoom_error => zoom_error,
                      :zoom_error_code => zoom_error_code,
                      :zoom_error_message => zoom_error_message,
                      :requestparams => requestparams,
                      :additionaldata => response)

    if(!response_error and !json_error and !zoom_error)
      return parsed_response
    else
      return nil
    end

  end

end
