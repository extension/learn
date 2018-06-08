class AddEventRedirection < ActiveRecord::Migration
  def change
    add_column(:events, :redirect_event, :boolean, :default => false)
    add_column(:events, :redirect_url, :text)
  end
end
