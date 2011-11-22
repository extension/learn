class CreateNotifications < ActiveRecord::Migration
  def change
    create_table "notifications" do |t|
      t.references :learner
      t.references :event
      t.integer  "delivery_method", :null => false
      t.boolean  "sent", :null => false, :default => false
      t.boolean "silenced", :null => false, :default => false
      t.datetime "delivery_time", :null => false
      t.integer "delayed_job_id"
      t.timestamps
    end
  end
end
