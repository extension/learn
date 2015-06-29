class CreateRegistrations < ActiveRecord::Migration
  def change
  	create_table "event_registrations" do |t| 
      t.references :event
      t.text "first_name",   :null => false
      t.text "last_name",   :null => false
      t.text "email",   :null => false
      t.datetime   "created_at"
  	end
  end
end
