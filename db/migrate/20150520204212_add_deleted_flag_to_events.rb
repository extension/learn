class AddDeletedFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_deleted, :boolean, :null => false, :default => false
  end
end
