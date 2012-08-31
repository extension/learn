class AddConferences < ActiveRecord::Migration
  def change
    create_table "conferences" do |t|
      t.string "name", :null => false
      t.string "hashtag", :null => false
      t.string "tagline"
      t.string "website"
      t.text   "description"
      t.string   "time_zone"
      t.date   "start_date", :null => false
      t.date   "end_date", :null => false
      t.boolean "is_virtual", :default => false
      t.integer  "creator_id",                          :null => false
      t.integer  "last_modifier_id",                    :null => false
      t.timestamps
    end

    add_index "conferences", ["hashtag"], :name => "hashtag_ndx", :unique => true

    # column additions for events
    add_column("events","event_type",:string, :default => Event::ONLINE, :limit => 25)
    add_column("events","conference_id",:integer)
    add_column("events","room",:string)

    add_index("events",["conference_id"], :name => 'conference_ndx')
    add_index("events",["event_type"], :name => 'event_type_ndx')
    add_index("events",["room"], :name => 'room_ndx')

    # set all existing events to be general
    execute "UPDATE events SET event_type = '#{Event::ONLINE}'"
    
    create_table "conference_connections", :force => true do |t|
      t.integer  "learner_id", :null => false
      t.integer  "conference_id", :null => false
      t.integer  "connectiontype", :null => false
      t.string   "role_description"
      t.datetime "created_at"
    end

    add_index "conference_connections", ["learner_id", "conference_id", "connectiontype"], :name => "connection_ndx", :unique => true

    # # evaluation questions and answers
    # create_table "evaluation_questions", :force => true do |t|
    #   t.references  :conference
    #   t.text     "prompt"
    #   t.string   "responsetype"
    #   t.text     "responses"
    #   t.integer  "range_start"
    #   t.integer  "range_end"
    #   t.integer  "creator_id"
    #   t.timestamps 
    # end

    # add_index('evaluation_questions', ['conference_id'], :name => 'conference_ndx')

    # create_table "evaluation_answers", :force => true do |t|
    #   t.integer  "evaluation_question_id", :null => false
    #   t.integer  "learner_id",  :null => false
    #   t.integer  "event_id",  :null => false
    #   t.text     "response"
    #   t.integer  "value"
    #   t.timestamps
    # end

    # add_index "evaluation_answers", ["evaluation_question_id", "learner_id", "event_id"], :name => "question_answer_learner_ndx", :unique => true


    # Create nexc2012 to have something to work against
    # change learnbots name to something friendlier because 'Learn System User' looks stupid
    Learner.learnbot.update_attribute(:name, 'Learn')

    Conference.reset_column_information
    Conference.create(:name => 'eXtension 2012 National Conference', 
                      :hashtag => 'nexc2012', 
                      :tagline => 'SPUR ON the Evolution of Extension',
                      :website => 'http://nexc2012.extension.org',
                      :description => 'To be added.',
                      :start_date => '2012-10-01',
                      :end_date => '2012-10-04',
                      :creator => Learner.learnbot,
                      :last_modifier => Learner.learnbot,
                      :time_zone => 'Central Time (US & Canada)',
                      :is_virtual => false)

  



  end
end
