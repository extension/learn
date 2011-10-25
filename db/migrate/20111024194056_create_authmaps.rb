class CreateAuthmaps < ActiveRecord::Migration
  def change
    create_table :authmaps do |t|
      t.integer :learner_id, :null => false
      t.string :authname, :null => false
      t.string :source, :null => false
      t.timestamps
    end
    
    add_index :authmaps, :learner_id
    add_index(:authmaps, [:authname, :source], :unique => true)
  end
end
