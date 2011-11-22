# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateEventConnections < ActiveRecord::Migration
  def change
    create_table "event_connections" do |t|
        t.references :learner
        t.references :event
        t.integer  "connectiontype",   :null => false
        t.datetime   "created_at"
    end
    add_index "event_connections", ["learner_id","event_id", "connectiontype"], :name => "connection_ndx", :unique => true
  end
end
