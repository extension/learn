class Notification < ActiveRecord::Base
  
  #belongs_to :event
  belongs_to :notifiable, :polymorphic => true
  after_create :queue_delayed_notifications
  after_update :update_delayed_notifications


  EVENT_REMINDER_EMAIL = 1
  EVENT_REMINDER_SMS = 2
  EVENT_EDIT = 3
  EVENT_CANCELED = 4
  EVENT_RESCHEDULED = 5
  ACTIVITY = 10
  COMMENT_REPLY = 11
  ACTIVITY_NOTIFICATION_INTERVAL = Settings.activity_notification_interval
  RESCHEDULED_NOTIFICATION_INTERVAL = Settings.rescheduled_notification_interval
  RECORDING = 20
  RECOMMENDATION = 30
  INFORM_IASTATE = 40
  UPDATE_IASTATE = 41
  CANCELED_IASTATE = 42
  
  
  def process
    return true if !Settings.send_notifications
    
    if (self.notifiable_type == 'Event') && (Event.find_by_id(self.notifiable_id).is_canceled == true) && (self.notificationtype != EVENT_CANCELED or self.notificationtype != CANCELED_IASTATE)
      return true
    end
    
    case self.notificationtype
    when EVENT_REMINDER_EMAIL
      process_event_reminder_emails
    when EVENT_REMINDER_SMS
      process_event_reminder_sms
    when EVENT_EDIT
      process_event_edit
    when EVENT_CANCELED
      process_event_canceled
    when EVENT_RESCHEDULED
      process_event_rescheduled
    when ACTIVITY
      process_activity_notifications
    when COMMENT_REPLY
      process_comment_reply
    when RECORDING
      process_recording_notifications
    when RECOMMENDATION
      process_recommendation
    when INFORM_IASTATE
      process_inform_iastate
    when UPDATE_IASTATE
      process_update_iastate
    when CANCELED_IASTATE
      process_canceled_iastate
    else
      # nothing
    end
  end
  
  def process_event_reminder_emails
    self.notifiable.learners.each{|learner| EventMailer.reminder(learner: learner, event: self.notifiable).deliver unless !learner.send_reminder? or learner.has_event_notification_exception?(self.notifiable)}      
  end

  def process_event_reminder_sms
    self.notifiable.learners.each{|learner| send_sms_notification(learner) unless !learner.send_sms?(self.offset) or learner.has_event_notification_exception?(self.notifiable)}      
  end  

  def process_activity_notifications
    self.notifiable.learners.each{|learner| EventMailer.activity(learner: learner, event: self.notifiable).deliver unless !learner.send_activity? or learner.has_event_notification_exception?(self.notifiable)}      
  end
  
  #still need to implement email
  def process_recording_notifications
    self.notifiable.learners.each{|learner| EventMailer.recording(learner: learner, event: self.notifiable).deliver unless !learner.send_recording? or learner.has_event_notification_exception?(self.notifiable)}      
  end
  
  def process_comment_reply
    comment = self.notifiable
    learner = comment.parent.learner
    event = self.notifiable.event
    EventMailer.comment_reply(learner: learner, comment: comment).deliver unless !learner.send_activity? or learner.has_event_notification_exception?(event)
  end
  
  def process_event_edit
    learner = self.notifiable.creator
    event= self.notifiable
    EventMailer.event_edit(learner: learner, event: event).deliver unless !learner.send_reminder? or learner.has_event_notification_exception?(event)
  end
  
  def process_event_canceled
    event = self.notifiable
    if !event.started?
      event.learners.each{|learner| EventMailer.event_canceled(learner: learner, event: event).deliver unless !learner.send_rescheduled_or_canceled? or learner.has_event_notification_exception?(event)}
      EventMailer.event_canceled(learner: Learner.learnbot, event: event).deliver
      EventMailer.inform_iastate_canceled(event: event).deliver
    end
  end
  
  def process_event_rescheduled
    event = self.notifiable
    if !event.started?
      event.learners.each{|learner| EventMailer.event_rescheduled(learner: learner, event: event).deliver unless !learner.send_rescheduled_or_canceled? or learner.has_event_notification_exception?(event)}
    end    
  end
  
  def process_recommendation
    recommendation = self.notifiable
    # doublecheck delivery setting
    if(recommendation.learner.send_recommendation?)
      EventMailer.recommendation(recommendation: recommendation).deliver
    end
  end
  
  def process_inform_iastate
    event = self.notifiable
    EventMailer.inform_iastate_new(event: event) unless event.started?
  end

  def process_update_iastate
    event = self.notifiable
    EventMailer.inform_iastate_update(event: event) unless event.started?
  end
  
  def process_canceled_iastate
    event = self.notifiable
    EventMailer.inform_iastate_canceled(event: event) unless event.started?
  end
  
  def queue_delayed_notifications
    delayed_job = Delayed::Job.enqueue(NotificationJob.new(self.id), {:priority => 0, :run_at => self.delivery_time})
    self.update_attribute(:delayed_job_id, delayed_job.id)
  end
  
  def update_delivery_time(delivery_time)
    self.update_attribute(:delivery_time, delivery_time - self.offset)
  end
  
  def update_delayed_notifications
      delayed_job = Delayed::Job.find_by_id(self.delayed_job_id)
      delayed_job.update_attributes(:run_at => self.delivery_time) if !delayed_job.nil?
  end
  
  def sms_message(learner)
    "\"#{self.notifiable.title.truncate(80, separator: ' ')}\" is starting soon! #{self.notifiable.session_start.in_time_zone(learner.time_zone).strftime("%I:%M%p %Z")} @ #{Settings.urlwriter_host}/events/#{self.notifiable.id}"
  end
  
  
  def send_sms_notification(learner)
    if !learner.mobile_number.nil?
      uri = URI(Settings.tropo_url)
      params = { :action => "create", :token => Settings.tropo_token, :remindermessage => self.sms_message(learner), :phonenumbers => learner.mobile_number }
      result = Net::HTTP.post_form(uri,params)
      if result.is_a?(Net::HTTPSuccess)
        return true
      else
        return false
      end
    end
  end
  
  def self.pending_activity_notification?(notifiable)
    Notification.where(notifiable_id: notifiable.id, notificationtype: ACTIVITY, delivery_time: Time.now..ACTIVITY_NOTIFICATION_INTERVAL.from_now).size > 0
  end
  
  def self.pending_rescheduled_notification?(notifiable)
    Notification.where(notifiable_id: notifiable.id, notificationtype: EVENT_RESCHEDULED, delivery_time: Time.now..RESCHEDULED_NOTIFICATION_INTERVAL.from_now).size > 0
  end
  

end
