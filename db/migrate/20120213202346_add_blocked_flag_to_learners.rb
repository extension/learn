class AddBlockedFlagToLearners < ActiveRecord::Migration
  def change
    add_column :learners, :is_blocked, :boolean, :null => false, :default => false
  end
end
