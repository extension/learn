# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateLearners < ActiveRecord::Migration
  def change
    create_table "learners" do |t|
      # creates :email (string) 
      # creates :encrypted_password field (string) 
      # we are letting these fields be null to cover certain cases of scientist records like twitter authentication via oauth
      # that does not give us an email address and we"re not storing a pw for it
      t.database_authenticatable :null => true
      # does not create :remember_token(string), not sure why right now, default is supposed to create it
      # creates :remember_created_at(Datetime)
      t.rememberable
      # creates :sign_in_count (Integer)
      # creates :current_sign_in_at (Datetime)
      # creates :last_sign_in_at (Datetime)
      # creates :current_sign_in_ip (string)
      # creates :last_sign_in_ip (string)
      t.trackable
      t.string "name"
      t.string "time_zone"
      t.string "mobile_number"
      t.string "bio"
      t.string "avatar"
      t.boolean "has_profile", :null => false, :default => false
      t.integer "darmok_id"
      t.boolean "retired", :null => false, :default => false
      t.boolean "is_admin", :null => false, :default => false
      t.timestamps
    end
    
    add_index "learners", ["email"]
  end
end
