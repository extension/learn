class CreatePresenterConnections < ActiveRecord::Migration
  def change
    create_table "presenter_connections" do |t|
      t.references :learner
      t.references  :event
      t.datetime   "created_at"
    end
    add_index "presenter_connections", ["learner_id","event_id"], :name => "connection_ndx", :unique => true
  end
end
