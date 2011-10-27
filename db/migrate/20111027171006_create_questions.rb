# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text 'prompt'
      t.string 'responsetype'
      t.text 'responses'
      t.integer 'range_start'
      t.integer 'range_end'
      t.integer 'priority'
      t.references :event
      t.references :creator
      t.timestamps
    end
  end
end
