# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomRegistration < ActiveRecord::Base
  serialize :additionaldata
  attr_accessible :event, :event_id, :learner, :learner_id, :event_connection, :event_connection_id
  attr_accessible :zoom_webinar_id, :zoom_user_id, :first_name, :last_name, :email, :attended, :additionaldata, :registered_at
  attr_accessible :time_in_session

  belongs_to :event
  belongs_to :learner
  belongs_to :event_connection

  # after_create  :create_event_connection


  def self.get_zoom_registration_list(event)
    return false if(!event.is_zoom_webinar? or event.zoom_webinar_id.blank?)
    request_type = ZoomEventConnectionRequest::REQUEST_REGISTRANTS
    request_log = ZoomEventConnectionRequest.create(event: event, request_type: request_type)
    if(registrants = ZoomApi.get_zoom_webinar_registration_list(event.zoom_webinar_id, {request_id: request_log.id}))
      registrants.each do |registration|
        next if(registration["email"].blank?)
        self.create_or_update_registration(event,registration)
      end
      request_log.update_attributes(success: true, completed_at: Time.now.utc)
    else
      request_log.update_attributes(success: false, completed_at: Time.now.utc)
    end
  end

  def self.get_zoom_attendee_list(event)
    return false if(!event.is_zoom_webinar? or event.zoom_webinar_id.blank? or !event.concluded?)
    request_type = ZoomEventConnectionRequest::REQUEST_ATTENDEES
    request_log = ZoomEventConnectionRequest.create(event: event, request_type: request_type)
    if(attendees = ZoomApi.get_zoom_webinar_attendee_list(event.zoom_webinar_id, {request_id: request_log.id}))
      attendees_hash = {}
      attendees.each do |attendance|
        next if(attendance["email"].blank?)
        # the attendee list can have multiple records per email, so let's reduce it down
        if(attendees_hash[attendance["email"]])
          attendees_hash[attendance["email"]][:time_in_session] += attendance["time_in_session"].to_i
        else
          attendees_hash[attendance["email"]] = {
            :first_name => attendance["first_name"],
            :last_name => attendance["last_name"],
            :attended => (attendance["attended"] == 'Yes'),
            :additionaldata => {"custom_questions" => attendance["custom_questions"], "questions" => attendance["questions"]},
            :time_in_session => attendance["time_in_session"].to_i
          }
        end
      end
      attendees_hash.each do |email,attendance|
        self.update_attendance(event,email,attendance)
      end
      request_log.update_attributes(success: true, completed_at: Time.now.utc)
    else
      request_log.update_attributes(success: false, completed_at: Time.now.utc)
    end
  end

  def self.get_zoom_list_for_event(event)
    return false if(!event.is_zoom_webinar? or event.zoom_webinar_id.blank?)
    if(event.concluded?)
      self.get_zoom_registration_list(event)
      self.get_zoom_attendee_list(event)
    else
      self.get_zoom_registration_list(event)
    end
  end

  def self.create_or_update_registration(event,registration)
    if(registration["approval"] == "approved")
      learner = Learner.where(email: registration["email"]).first
      if(zr = self.where(event_id: event.id).where(email: registration["email"]).first)
        zr.update_attributes(learner: learner,
                             registered_at: registration["create_time"],
                             first_name: registration[:first_name],
                             last_name: registration[:last_name],
                             zoom_user_id: registration["id"],
                             zoom_webinar_id: event.zoom_webinar_id)
      else
        zr = self.create(event: event,
                         email: registration["email"],
                         learner: learner,
                         registered_at: registration["create_time"],
                         first_name: registration[:first_name],
                         last_name: registration[:last_name],
                         zoom_user_id: registration["id"],
                         zoom_webinar_id: event.zoom_webinar_id)
      end
      true
    elsif(registration["approval"] =~ %r{^cancelled})
      if(zr = self.where(event_id: event.id).where(email: registration["email"]).first)
        zr.destroy
      end
      false
    end
  end

  def self.update_attendance(event,email,attendance)
    if(zr = self.where(event_id: event.id).where(email: email).first)
      zr.update_attributes(attendance)
    end
  end

  # def create_event_connection
  #   true
  # end


end
