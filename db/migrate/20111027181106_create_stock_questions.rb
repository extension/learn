# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateStockQuestions < ActiveRecord::Migration
  def change
    create_table :stock_questions do |t|
      t.boolean 'active'
      t.text 'prompt'
      t.string 'responsetype'
      t.text 'responses'
      t.integer 'range_start'
      t.integer 'range_end'
      t.references :creator
      t.timestamps
    end
  end
end
