class CleanupRegistration < ActiveRecord::Migration
  def up
    remove_column(:events, :registration_contact_id)
    execute "DELETE event_registrations.* from event_registrations,events WHERE event_registrations.event_id = events.id and events.is_mfln = 0;"
    execute "UPDATE events set requires_registration = 0 where is_mfln = 0;"
  end

  def down
  end
end
