# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateMailerCaches < ActiveRecord::Migration
  def change
    create_table :mailer_caches do |t|
      t.string "hashvalue", :limit => 40, :null => false
      t.references :learner
      # intentionally not using t.references
      # so that we can limit the size of the type
      # and tighten any future indexing
      t.integer    "cacheable_id"
      t.string     "cacheable_type", limit: 30
      t.text "markup", :limit => (64.kilobytes + 1)
      t.timestamps
    end
    
    add_index "mailer_caches", ["hashvalue"], :uniq => true, :name => 'hashvalue_ndx'
    add_index "mailer_caches", ["learner_id"]
  end
end
