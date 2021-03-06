# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateAnswers < ActiveRecord::Migration
  def change
    create_table "answers" do |t|
      t.references :question, :null => false
      t.references :learner, :null => false
      t.string "response"
      t.integer "value"
      t.timestamps
    end
    
    add_index "answers", ["question_id", "learner_id", "response"], :unique => true
  end
end
