class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content, :null => false
      t.string :ancestry
      t.integer :learner_id, :null => false
      t.integer :event_id, :null => false
      t.boolean :parent_removed, :default => false
      t.timestamps
    end
    
    add_index :comments, :ancestry
    add_index :comments, :learner_id
    add_index :comments, :event_id
  end
end
