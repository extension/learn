# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111104001730) do

  create_table "answers", :force => true do |t|
    t.integer  "question_id", :null => false
    t.integer  "learner_id",  :null => false
    t.string   "response"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id", "learner_id", "response"], :name => "index_answers_on_question_id_and_learner_id_and_response", :unique => true

  create_table "authmaps", :force => true do |t|
    t.integer  "learner_id", :null => false
    t.string   "authname",   :null => false
    t.string   "source",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authmaps", ["authname", "source"], :name => "index_authmaps_on_authname_and_source", :unique => true
  add_index "authmaps", ["learner_id"], :name => "index_authmaps_on_learner_id"

  create_table "comments", :force => true do |t|
    t.text     "content",                           :null => false
    t.string   "ancestry"
    t.integer  "learner_id",                        :null => false
    t.integer  "event_id",                          :null => false
    t.boolean  "parent_removed", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["ancestry"], :name => "index_comments_on_ancestry"
  add_index "comments", ["event_id"], :name => "index_comments_on_event_id"
  add_index "comments", ["learner_id"], :name => "index_comments_on_learner_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "event_activities", :force => true do |t|
    t.integer  "learner_id",                                  :null => false
    t.integer  "event_id"
    t.integer  "activity"
    t.integer  "loggable_id"
    t.string   "loggable_type",  :limit => 30
    t.integer  "activity_count",               :default => 1, :null => false
    t.datetime "created_at"
  end

  add_index "event_activities", ["learner_id", "event_id", "activity", "loggable_id", "loggable_type"], :name => "activity_uniq_ndx", :unique => true

  create_table "event_connections", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "event_id"
    t.integer  "connectiontype", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_connections", ["learner_id", "event_id", "connectiontype"], :name => "connection_ndx"

  create_table "events", :force => true do |t|
    t.text     "title",            :null => false
    t.text     "description",      :null => false
    t.datetime "session_start",    :null => false
    t.datetime "session_end",      :null => false
    t.integer  "session_length",   :null => false
    t.text     "location"
    t.text     "recording"
    t.integer  "creator_id",       :null => false
    t.integer  "last_modifier_id", :null => false
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "learners", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",  :limit => 128
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "time_zone"
    t.string   "mobile_number"
    t.boolean  "has_profile",         :default => false, :null => false
    t.integer  "darmok_id"
    t.boolean  "retired",             :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "learners", ["email"], :name => "index_learners_on_email"

  create_table "questions", :force => true do |t|
    t.text     "prompt"
    t.string   "responsetype"
    t.text     "responses"
    t.integer  "range_start"
    t.integer  "range_end"
    t.integer  "priority"
    t.integer  "event_id",     :null => false
    t.integer  "learner_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rateable_id",   :null => false
    t.string   "rateable_type", :null => false
    t.integer  "score",         :null => false
    t.integer  "learner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["learner_id", "rateable_type", "rateable_id"], :name => "index_ratings_on_learner_id_and_rateable_type_and_rateable_id"

  create_table "stock_questions", :force => true do |t|
    t.boolean  "active"
    t.text     "prompt"
    t.string   "responsetype"
    t.text     "responses"
    t.integer  "range_start"
    t.integer  "range_end"
    t.integer  "learner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "taggingindex", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

end
