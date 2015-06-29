class AddRegistrationContactToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :registration_contact_id, :integer
  end
end
