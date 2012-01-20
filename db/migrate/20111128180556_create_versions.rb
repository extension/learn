class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string   "item_type", :null => false
      t.integer  "item_id",   :null => false
      t.string   "event",     :null => false
      t.string   "whodunnit"
      t.string   "ipaddress"
      t.text     "object"
      t.text     "object_changes"
      t.datetime "created_at"
    end
    
    # make absolutely sure that object and object_changes are mediumtext
    execute "ALTER TABLE `versions` CHANGE COLUMN `object` `object` MEDIUMTEXT"
    execute "ALTER TABLE `versions` CHANGE COLUMN `object_changes` `object_changes` MEDIUMTEXT"
    
    add_index "versions", ["item_type", "item_id"]
    
    
  end
end
