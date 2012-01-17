class CreatePortfolioSettings < ActiveRecord::Migration
  def change
    create_table :portfolio_settings do |t|
      t.text :currently_learning, :null => true
      t.text :learning_plan, :null => true
      t.integer :learner_id, :null => false
      t.timestamps
    end
    
    add_index :portfolio_settings, :learner_id, :unique => true
  end
end
