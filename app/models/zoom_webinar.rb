# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomWebinar < ActiveRecord::Base
  serialize :uuidlist
  serialize :webinar_info
  attr_accessible :event, :event_id, :webinar_id
  attr_accessible :webinar_type, :recurring, :has_registration_url, :api_success
  attr_accessible :webinar_created_at, :uuidlist, :webinar_info

  INVALID_WEBINAR  = -1
  INELIGIBLE_WEBINAR = -11
  NOT_ZOOM_WEBINAR = 0

  # types
  REGULAR_WEBINAR = 5
  RECURRING_WEBINAR = 6
  FIXED_RECURRING_WEBINAR = 9

  def self.create_from_event(event)
    if(!webinar_id = event.zoom_webinar_id_from_location)
      event.update_column(:zoom_webinar_id, Event::NOT_ZOOM_WEBINAR)
      return false
    end
    create_attributes = {
      event_id: event.id,
      webinar_id: webinar_id
    }

    if(!webinarinfo = ZoomApi.get_zoom_webinar(webinar_id))
      begin
        self.create(create_attributes.merge(api_success: false))
        event.update_column(:zoom_webinar_id, Event::INVALID_WEBINAR)
      rescue ActiveRecord::RecordNotUnique => e
        event.update_column(:zoom_webinar_id, Event::INVALID_WEBINAR)
      end
      return false
    end

    infoattributes = {
      webinar_type: webinarinfo["type"],
      recurring: ([RECURRING_WEBINAR,FIXED_RECURRING_WEBINAR].include?(webinarinfo["type"].to_i)),
      has_registration_url: !(webinarinfo["registration_url"].blank?),
      api_success: true,
      webinar_created_at: webinarinfo["create_time"],
      webinar_info: webinarinfo
    }

    begin
      if(infoattributes[:recurring])
        event_zw_id = Event::INELIGIBLE_WEBINAR
        create_attributes[:event_id] = nil
      end
      zw = self.create(create_attributes.merge(infoattributes))
      zw.update_attribute(:uuidlist, ZoomApi.get_zoom_webinar_uuid_list(webinar_id))
      event.update_column(:zoom_webinar_id, event_zw_id)
    rescue ActiveRecord::RecordNotUnique => e
      if(infoattributes[:recurring])
        event_zw_id = Event::INELIGIBLE_WEBINAR
        infoattributes[:event_id] = nil
      end
      zw = self.where(webinar_id: webinar_id).first
      zw.update_attributes(infoattributes)
      zw.update_attribute(:uuidlist, ZoomApi.get_zoom_webinar_uuid_list(webinar_id))
      event.update_column(:zoom_webinar_id, event_zw_id)
    end
    return true
  end




  def set_zoom_webinar_uuid
    return false if(!self.concluded?)
    return false if(self.zoom_webinar_id.blank?)
    uuidlist = ZoomApi.get_zoom_webinar_uuid_list(self.zoom_webinar_id)
    return false if uuidlist.blank?
    founduuid = ''
    minimumtime = ''
    uuidlist.each do |occurrence|
      if(!occurrence["start_time"].blank? and !occurrence["uuid"].blank?)
        puts "Here!  #{occurrence} #{minimumtime} #{founduuid}"
        uuidtime = Time.parse(occurrence["start_time"])
        timebetween = (self.session_start - uuidtime).abs
        if(minimumtime.blank? or minimumtime >= timebetween)
          founduuid = occurrence["uuid"]
          minimumtime = timebetween
        end
      end
    end
    self.update_column(:zoom_webinar_uuid, founduuid) if !founduuid.blank?
  end


end
