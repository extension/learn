class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      t.references :learner, :null => false
      t.references :event
      t.integer    :activity
      t.references :loggable, :polymorphic => true
      t.integer    :ipaddr      
      t.datetime   :created_at
    end

  end
end
