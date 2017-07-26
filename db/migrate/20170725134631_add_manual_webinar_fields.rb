class AddManualWebinarFields < ActiveRecord::Migration
  def change
    add_column(:zoom_webinars, :manual_connections, :boolean, :default => false)
    add_column(:zoom_webinars, :manual_attendance, :text, :limit => 16777215)
    add_column(:zoom_webinars, :manual_registration, :text, :limit => 16777215)

    # fix data for events to set the webinar id for WEBINAR_STATUS_RETRIEVAL_ERROR
    execute "UPDATE events,zoom_webinars SET events.zoom_webinar_id = zoom_webinars.id WHERE zoom_webinars.event_id = events.id AND events.zoom_webinar_status = #{Event::WEBINAR_STATUS_RETRIEVAL_ERROR}"
  end
end
