class AddSomeIndexes < ActiveRecord::Migration
  def change
    change_column("event_registrations",:first_name, :string)
    change_column("event_registrations",:last_name, :string)
    change_column("event_registrations",:email, :string)
    add_index "event_registrations", ["email", "event_id"], :name => "registration_ndx", :unique => true
  end
end
