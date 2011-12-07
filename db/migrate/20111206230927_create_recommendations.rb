# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.references :learner
      t.date       "day"
      t.timestamps
    end
    
    add_index "recommendations", ["learner_id","day"], :uniq => true, :name => "recommendation_ndx"
  end
end
