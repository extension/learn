# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateComments < ActiveRecord::Migration
  def change
    create_table "comments" do |t|
      t.text "content", :null => false
      t.string "ancestry"
      t.references :learner, :null => false
      t.integer "event_id", :null => false
      t.boolean "parent_removed", :default => false
      t.timestamps
    end
    
    #TODO: combine these?
    add_index "comments", ["ancestry"]
    add_index "comments", ["learner_id","event_id"]
  end
end
