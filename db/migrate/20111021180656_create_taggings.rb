# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateTaggings < ActiveRecord::Migration
  def change
    create_table "taggings" do |t|
      t.references :tag
      t.references :taggable, :polymorphic => true
      t.timestamps
    end
    add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "taggingindex", :unique => true
  end
end
