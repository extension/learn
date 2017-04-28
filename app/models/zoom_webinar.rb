# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomWebinar < ActiveRecord::Base
  serialize :uuidlist
  serialize :webinar_info
  attr_accessible :event, :event_id, :webinar_id
  attr_accessible :webinar_type, :recurring, :has_registration_url, :last_api_success
  attr_accessible :webinar_created_at, :uuidlist, :webinar_info

  belongs_to :event

  # types
  REGULAR_WEBINAR = 5
  RECURRING_WEBINAR = 6
  FIXED_RECURRING_WEBINAR = 9

  def self.create_or_update_from_event(event)
    return false if(event.location_webinar_id.blank?)

    webinar_id = event.location_webinar_id

    create_attributes = {
      event_id: event.id,
      webinar_id: webinar_id
    }

    if(!webinarinfo = ZoomApi.get_zoom_webinar(webinar_id))
      if(!zw = self.where(webinar_id: webinar_id).first)
        self.create(create_attributes.merge(last_api_success: false))
        event.update_column(:zoom_webinar_status, Event::WEBINAR_STATUS_TEMPORARY_RETRIEVAL_ERROR)
      else
        # was last pull successful - mark as temporary failed
        if(zw.last_api_success?)
          self.create(create_attributes.merge(last_api_success: false))
          event.update_column(:zoom_webinar_status, Event::WEBINAR_STATUS_TEMPORARY_RETRIEVAL_ERROR)
        else
          event.update_column(:zoom_webinar_id, nil)
          event.update_column(:zoom_webinar_status, Event::WEBINAR_STATUS_RETRIEVAL_ERROR)
        end
      end
    else
      # got webinar info
      infoattributes = {
        webinar_type: webinarinfo["type"],
        recurring: ([RECURRING_WEBINAR,FIXED_RECURRING_WEBINAR].include?(webinarinfo["type"].to_i)),
        has_registration_url: !(webinarinfo["registration_url"].blank?),
        last_api_success: true,
        webinar_created_at: webinarinfo["created_at"],
        webinar_info: webinarinfo
      }

      if(!zw = self.where(webinar_id: webinar_id).first)
        if(infoattributes[:recurring])
          create_attributes[:event_id] = nil
        end
        zw = self.create(create_attributes.merge(infoattributes))
        zw.update_attribute(:uuidlist, ZoomApi.get_zoom_webinar_uuid_list(webinar_id))
      else
        if(infoattributes[:recurring])
          infoattributes[:event_id] = nil
        end
        zw.update_attributes(infoattributes)
        zw.update_attribute(:uuidlist, ZoomApi.get_zoom_webinar_uuid_list(webinar_id))
      end

      if(!zw.recurring?)
        event.update_column(:zoom_webinar_id, zw.id)
        event.update_column(:zoom_webinar_status, Event::WEBINAR_STATUS_OK)
      else
        event.update_column(:zoom_webinar_id, zw.id)
        event.update_column(:zoom_webinar_status, Event::WEBINAR_STATUS_IS_RECURRING)
      end
    end # retrieval successful
  end

  def uuid_for_event
    event = self.event
    return nil if(event.nil?)
    return nil if(!event.concluded?)
    return nil if self.uuidlist.blank?
    founduuid = ''
    minimumtime = ''
    uuidlist.each do |occurrence|
     if(!occurrence["start_time"].blank? and !occurrence["uuid"].blank?)
       uuidtime = Time.parse(occurrence["start_time"])
       timebetween = (event.session_start - uuidtime).abs
       if(minimumtime.blank? or minimumtime >= timebetween)
         founduuid = occurrence["uuid"]
         minimumtime = timebetween
       end
     end
    end
    founduuid
  end


  def get_zoom_connections
    if(self.has_registration_url?)
      ZoomConnection.get_zoom_registration_list(self)
    end

    if(self.event and self.event.concluded?)
      ZoomConnection.get_zoom_attendee_list(self,self.uuid_for_event)
    end
  end

end
