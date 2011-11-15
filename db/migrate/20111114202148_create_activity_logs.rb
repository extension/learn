class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table "activity_logs" do |t|
      t.references :learner, :null => false
      # intentionally not using t.references
      # so that we can limit the size of the type
      # and tighten the index
      t.integer    "loggable_id"
      t.string     "loggable_type", limit: 30
      t.integer    "ipaddr"
      t.text       "additional"
      t.datetime   "created_at"
    end
    
    add_index "activity_logs", ["learner_id", "loggable_id", "loggable_type"], :name => "activity_ndx"
    
  end
end
