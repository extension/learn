# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomConnection < ActiveRecord::Base
  serialize :additionaldata
  attr_accessible :event, :event_id, :learner, :learner_id, :event_connection, :event_connection_id
  attr_accessible :zoom_webinar, :zoom_webinar_id, :zoom_user_id, :first_name, :last_name, :email, :additionaldata
  attr_accessible :time_in_session, :registered_at, :attended_at
  attr_accessible :registered, :panelist, :attended, :zoom_uuid

  belongs_to :event
  belongs_to :learner
  belongs_to :event_connection
  belongs_to :zoom_webinar

  after_save :update_event_connection

  scope :attended, ->{where(attended: true)}
  scope :registered, ->{where(registered: true)}
  scope :learners, ->{where("learner_id IS NOT NULL")}

  def associate_to_learner
    if(learner = Learner.extension.where(email: self.email).first)
      self.update_column(:learner_id, learner.id)
    else
      self.update_column(:learner_id,nil)
    end
  end

  def self.associate_to_learners
    self.find_each do |zc|
      zc.associate_to_learner
    end
  end


  def self.get_zoom_registration_list(zoom_webinar)
    if(registrants = ZoomApi.get_zoom_webinar_registration_list(zoom_webinar.webinar_id))
      registrants.each do |registration|
        next if(registration["email"].blank?)
        self.create_or_update_registration(zoom_webinar,registration)
      end
      return true
    else
      return false
    end
  end

  def self.get_zoom_attendee_list(zoom_webinar,zoom_webinar_uuid)
    if(attendees = ZoomApi.get_zoom_webinar_attendee_list(zoom_webinar.webinar_id, zoom_webinar_uuid))
      attendees_hash = {}
      attendees.each do |attendance|
        next if(attendance["email"].blank?)
        # the attendee list can have multiple records per email, so let's reduce it down
        if(attendees_hash[attendance["email"]])
          attendees_hash[attendance["email"]][:time_in_session] += attendance["time_in_session"].to_i
        else
          attendees_hash[attendance["email"]] = {
            :zoom_webinar_id => zoom_webinar.id,
            :zoom_uuid => zoom_webinar_uuid,
            :first_name => attendance["first_name"],
            :last_name => attendance["last_name"],
            :attended => (attendance["attended"] == 'Yes'),
            :additionaldata => {"custom_questions" => attendance["custom_questions"], "questions" => attendance["questions"]},
            :attended_at => attendance["join_time"],
            :time_in_session => attendance["time_in_session"].to_i
          }
        end
      end
      attendees_hash.each do |email,attendance|
        self.create_or_update_attendance(zoom_webinar,email,attendance)
      end
      return true
    else
      return false
    end
  end



  def self.create_or_update_registration(zoom_webinar,registration)
    if(registration["approval"] == "approved")
      learner = Learner.where(email: registration["email"]).first
      if(zc = self.where(zoom_webinar_id: zoom_webinar.id).where(email: registration["email"]).first)
        zc.update_attributes(learner: learner,
                             event_id: zoom_webinar.event_id,
                             registered_at: registration["create_time"],
                             first_name: registration[:first_name],
                             last_name: registration[:last_name],
                             registered: true,
                             zoom_user_id: registration["id"])
      else
        zc = self.create(zoom_webinar_id: zoom_webinar.id,
                         event_id: zoom_webinar.event_id,
                         email: registration["email"],
                         learner: learner,
                         registered_at: registration["create_time"],
                         first_name: registration[:first_name],
                         last_name: registration[:last_name],
                         zoom_user_id: registration["id"],
                         registered: true)
      end
      true
    elsif(registration["approval"] =~ %r{^cancelled})
      if(zc = self.where(event_id: event.id).where(email: registration["email"]).first)
        zc.destroy
      end
      false
    end
  end

  def self.create_or_update_attendance(zoom_webinar,email,attendance)
    learner = Learner.extension.where(email: email).first
    if(zc = self.where(zoom_webinar_id: zoom_webinar.id).where(email: email).first)
      zc.update_attributes(attendance.merge({learner: learner, zoom_webinar_id: zoom_webinar.id}))
    else
      zc = self.create(attendance.merge({learner: learner, zoom_webinar_id: zoom_webinar.id, email: email}))
    end
  end

  def update_event_connection
    return true if(self.learner_id.nil?)
    return true if(self.event_id.nil?)

    if(!self.attended.nil? and self.attended)
      connectiontype = EventConnection::ATTEND
    else
      connectiontype = EventConnection::FOLLOW
    end

    begin
      ec = EventConnection.create(learner_id: self.learner_id, event_id: self.event_id, connectiontype: connectiontype, added_by_api: true)
      self.update_column(:event_connection_id, ec.id)
    rescue ActiveRecord::RecordNotUnique => e
      # do nothing, already bookmarked
    end

  end

end
