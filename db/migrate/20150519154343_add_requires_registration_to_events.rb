class AddRequiresRegistrationToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :requires_registration, :boolean, :null => false, :default => false
  end
end
