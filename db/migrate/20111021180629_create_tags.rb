# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateTags < ActiveRecord::Migration
  def change
    create_table "tags" do |t|
      t.string   "name"
      t.datetime "created_at"
    end
    add_index "tags", ["name"], :unique => true
  end
end
