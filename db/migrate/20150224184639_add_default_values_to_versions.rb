class AddDefaultValuesToVersions < ActiveRecord::Migration
  def change
  	change_column :versions, :whodunnit, :string, :default => '1'
  	change_column :versions, :ipaddress, :string, :default => '127.0.0.1'

  	Version.where('whodunnit is NULL').update_all(whodunnit:'1', ipaddress: '127.0.0.1')

  end
end
