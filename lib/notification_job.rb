class NotificationJob < Struct.new (:notification_id)
  def perform
    notification = Notification.find_by_id(notification_id)
    !notification.nil? ? notification.process : false
  end
  
  def error(job, exception)
    Airbrake.notify(exception)
  end
end