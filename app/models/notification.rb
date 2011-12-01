class Notification < ActiveRecord::Base
  
  #belongs_to :event
  belongs_to :notifiable, :polymorphic => true
  after_create :queue_delayed_notifications
  after_update :update_delayed_notifications


  EVENT_REMINDER_EMAIL = 1
  EVENT_REMINDER_SMS = 2
  REMINDER_NOTIFICATION_EMAIL = 3 # could be used to queue non event-related notifications
  ACTIVITY = 10
  RECORDING = 20
  
  def process
    case self.notificationtype
    when EVENT_REMINDER_EMAIL
      process_event_reminder_emails
    when EVENT_REMINDER_SMS
      process_event_reminder_sms
    when ACTIVITY
      process_activity_notifications
    when RECORDING
      process_recording_notifications
    end
  end
  
  def process_event_reminder_emails
    if !self.processed
      list = get_event_notification_list('notification.reminder.email', true)
      puts "sending email to list"
      #EventMailer calls go here     
    end
  end

  #this can still be otimized greatly. passing tropo a comma-separated string of phone numbers would mean only POSTing once
  def process_event_reminder_sms
    if !self.processed
      puts "sending #{self.offset/60} minute sms notifications"
      list = get_event_notification_list('notification.reminder.sms.notice', self.offset)
      list.each{|learner| send_sms_notification(learner) unless learner.has_event_notification_exception?(self.notifiable)}      
    end
  end  

  def process_activity_notifications
    puts "sending activity updates"
    list = get_event_notification_list('notification.activity', true)
    list.each{|learner| puts "sending activity notification to #{learner.email}" unless learner.has_event_notification_exception?(self.notifiable)}
  end
  
  #still need to implement email
  def process_recording_notifications
    puts "sending recording information"
    list = get_event_notification_list('notification.recording', true)
    list.each{|learner| puts "sending recording notification to #{learner.email}" unless learner.has_event_notification_exception?(self.notifiable)}  
  end

  def queue_delayed_notifications
    delayed_job = Delayed::Job.enqueue(NotificationJob.new(self.id), {:priority => 0, :run_at => self.delivery_time})
    self.update_attribute(:delayed_job_id, delayed_job.id)
  end
  
  def update_delivery_time(delivery_time)
    self.update_attribute(:delivery_time, delivery_time - self.offset) unless delivery_time == self.delivery_time
  end
  
  def update_delayed_notifications
    if !self.processed
      delayed_job = Delayed::Job.find(self.delayed_job_id)
      delayed_job.update_attributes(:run_at => self.delivery_time)
    end
  end
  
  #notification_preference should be a value like notification.reminder.email, notification.reminder.sms, notification.activity, etc.
  def get_event_notification_list(notification_preference, value)
    self.notifiable.bookmarked.joins(:preferences).where(:preferences => {:name => notification_preference, :value => value})    
  end
  
  def send_sms_notification(learner)
    uri = URI(Settings.tropo_url)
    params = { :action => "create", :token => Settings.tropo_token, :remindermessage => "eXtension Learn Event Reminder: #{self.notifiable.title} begins at #{self.notifiable.session_start.in_time_zone(learner.time_zone).strftime("%I:%M%p %Z")}", :phonenumbers => learner.mobile_number }
    result = Net::HTTP.post_form(uri,params)
    if result.is_a?(Net::HTTPSuccess)
      return true
    else
      return false
    end
  end

end
