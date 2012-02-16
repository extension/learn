class AddCanceledFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_canceled, :boolean, :null => false, :default => false
  end
end
