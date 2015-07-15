class AddReasonToDeletedEvents < ActiveRecord::Migration
  def change
  	add_column :events, :reason_is_deleted, :text
  end
end
