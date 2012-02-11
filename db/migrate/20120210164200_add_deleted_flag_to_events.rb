class AddDeletedFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :deleted, :boolean, :null => false, :default => false
  end
end
