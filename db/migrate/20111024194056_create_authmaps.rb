# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateAuthmaps < ActiveRecord::Migration
  def change
    create_table "authmaps" do |t|
      t.references :learner, :null => false
      t.string "authname", :null => false
      t.string "source", :null => false
      t.timestamps
    end
    
    add_index "authmaps", ["learner_id"] 
    add_index "authmaps", ["authname", "source"], :unique => true
  end
end
