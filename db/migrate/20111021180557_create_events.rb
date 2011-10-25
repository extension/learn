class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text     "title",            :null => false
      t.text     "description",      :null => false
      t.datetime "session_start",    :null => false
      t.datetime "session_end",      :null => false
      t.integer  "session_length",   :null => false
      t.text     "location"
      t.text     "recording"
      t.integer  "created_by",       :null => false
      t.integer  "last_modified_by", :null => false
      t.string   "time_zone"
      t.timestamps
    end
  end
end