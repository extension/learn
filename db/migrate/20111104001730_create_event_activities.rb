class CreateEventActivities < ActiveRecord::Migration
  def change
    create_table :event_activities do |t|
      t.references :learner, :null => false
      t.references :event
      t.integer    "activity"
      # intentionally not using t.references
      # so that we can limit the size of the type
      # and tighten the index
      t.integer    "trackable_id"
      t.string     "trackable_type", limit: 30
      t.integer    "activity_count", default: 1, :null => false
      t.datetime   "updated_at"      
    end
    
    add_index("event_activities", ["learner_id", "event_id", "activity", "trackable_id", "trackable_type"], :unique => true, :name => "activity_uniq_ndx")
  end
end
