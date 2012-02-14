class AddIsExpiredToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_expired, :boolean, :null => false, :default => false
  end
end
