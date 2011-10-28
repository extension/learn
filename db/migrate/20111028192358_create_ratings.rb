class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :rateable_id, :null => false
      t.string :rateable_type, :null => false
      t.integer :score, :null => false
      t.integer :learner_id
      t.timestamps
    end
    
    add_index(:ratings, [:learner_id, :rateable_type, :rateable_id])
  end
end
