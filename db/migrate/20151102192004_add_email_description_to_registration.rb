class AddEmailDescriptionToRegistration < ActiveRecord::Migration
  def change
  	add_column :events, :registration_description, :text
  end

  def self.down
  	remove_column :events, :registration_description, :text
  end
end
