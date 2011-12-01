# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table "notifications" do |t|
      # intentionally not using t.references
      # so that we can limit the size of the type
      # and tighten the index
      t.integer    "notifiable_id"
      t.string     "notifiable_type", :limit => 30
      t.boolean  "processed", :null => false, :default => false
      t.integer "notificationtype", :null => false 
      t.datetime "delivery_time", :null => false
      t.integer "offset", :default => 0
      t.integer "delayed_job_id"
      t.timestamps
    end
  end
end
