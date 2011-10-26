class CreateEventConnections < ActiveRecord::Migration
  def change
    create_table :event_connections do |t|
        t.references :learner
        t.references :event
        t.integer  "connectiontype",   :null => false
        t.timestamps
    end
    add_index "event_connections", ["learner_id","event_id", "connectiontype"], :name => "connection_ndx"
  end
end
