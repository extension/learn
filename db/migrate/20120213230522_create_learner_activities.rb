class CreateLearnerActivities < ActiveRecord::Migration
  def change
    create_table :learner_activities do |t|
      t.integer    :learner_id, :null => false
      t.integer    :recipient_id, :null => false
      t.integer    :activity, :null => false  
      t.timestamps
    end
    
    add_index :learner_activities, [:learner_id, :recipient_id, :activity], :name => "learner_activity_ndx"
  end
end
