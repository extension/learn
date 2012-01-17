# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CreateRecommendedEvents < ActiveRecord::Migration
  def change
    create_table :recommended_events do |t|
      t.references :recommendation
      t.references :event
      t.boolean    "viewed", :default => false, :null => false
      t.timestamps
    end
    
    add_index "recommended_events", ["recommendation_id","event_id"], :uniq => true, :name => "recommended_event_ndx"
  end
end
