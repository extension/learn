class AddConferences < ActiveRecord::Migration
  def change
    create_table "conferences" do |t|
      t.string "name", :null => false
      t.string "hashtag", :null => false
      t.string "tagline"
      t.string "website"
      t.text   "description"
      t.date   "start_date", :null => false
      t.date   "end_date", :null => false
      t.timestamps
    end

    add_index "conferences", ["hashtag"], :name => "hashtag_ndx", :unique => true

    # column additions for events
    add_column("events","event_type",:string, :default => Event::GENERAL, :limit => 25)
    add_column("events","conference_id",:integer)
    add_column("events","room",:string)

    add_index("events",["conference_id"], :name => 'conference_ndx')
    add_index("events",["event_type"], :name => 'event_type_ndx')

    # set all existing events to be general
    execute "UPDATE events SET event_type = '#{Event::GENERAL}'"
    
    create_table "conference_connections", :force => true do |t|
      t.integer  "learner_id", :null => false
      t.integer  "conference_id", :null => false
      t.integer  "connectiontype", :null => false
      t.string   "role_description"
      t.datetime "created_at"
    end

    add_index "conference_connections", ["learner_id", "conference_id", "connectiontype"], :name => "connection_ndx", :unique => true

  end
end
