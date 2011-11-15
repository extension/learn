class CreateRatings < ActiveRecord::Migration
  def change
    create_table "ratings" do |t|
      t.references :rateable, :polymorphic => true, :null => false
      t.integer "score", :null => false
      t.references :learner
      t.timestamps
    end
    
    add_index "ratings", ["learner_id", "rateable_type", "rateable_id"]
  end
end
