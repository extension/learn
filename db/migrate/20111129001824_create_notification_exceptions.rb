# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateNotificationExceptions < ActiveRecord::Migration
  def change
    create_table "notification_exceptions" do |t|
        t.references :learner
        t.references :event
        t.datetime   "created_at"
    end
    add_index "notification_exceptions", ["learner_id","event_id"], :name => "connection_ndx", :unique => true
  end
end
