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

ActiveRecord::Schema.define(:version => 20120815134609) do

  create_table "activity_logs", :force => true do |t|
    t.integer  "learner_id",                  :null => false
    t.integer  "loggable_id"
    t.string   "loggable_type", :limit => 30
    t.integer  "ipaddr"
    t.text     "additional"
    t.datetime "created_at"
  end

  add_index "activity_logs", ["learner_id", "loggable_id", "loggable_type"], :name => "activity_ndx"

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
  add_index "comments", ["learner_id", "event_id"], :name => "index_comments_on_learner_id_and_event_id"

  create_table "conference_connections", :force => true do |t|
    t.integer  "learner_id",       :null => false
    t.integer  "conference_id",    :null => false
    t.integer  "connectiontype",   :null => false
    t.string   "role_description"
    t.datetime "created_at"
  end

  add_index "conference_connections", ["learner_id", "conference_id", "connectiontype"], :name => "connection_ndx", :unique => true

  create_table "conferences", :force => true do |t|
    t.string   "name",             :null => false
    t.string   "hashtag",          :null => false
    t.string   "tagline"
    t.string   "website"
    t.text     "description"
    t.string   "time_zone"
    t.date     "start_date",       :null => false
    t.date     "end_date",         :null => false
    t.integer  "creator_id",       :null => false
    t.integer  "last_modifier_id", :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "conferences", ["hashtag"], :name => "hashtag_ndx", :unique => true

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
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "event_activities", :force => true do |t|
    t.integer  "learner_id",                                  :null => false
    t.integer  "event_id"
    t.integer  "activity"
    t.integer  "trackable_id"
    t.string   "trackable_type", :limit => 30
    t.integer  "activity_count",               :default => 1, :null => false
    t.datetime "updated_at"
  end

  add_index "event_activities", ["learner_id", "event_id", "activity", "trackable_id", "trackable_type"], :name => "activity_uniq_ndx", :unique => true

  create_table "event_connections", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "event_id"
    t.integer  "connectiontype", :null => false
    t.datetime "created_at"
  end

  add_index "event_connections", ["learner_id", "event_id", "connectiontype"], :name => "connection_ndx", :unique => true

  create_table "events", :force => true do |t|
    t.text     "title",                                                 :null => false
    t.text     "description",                                           :null => false
    t.datetime "session_start",                                         :null => false
    t.datetime "session_end",                                           :null => false
    t.integer  "session_length",                                        :null => false
    t.text     "location"
    t.text     "recording"
    t.integer  "creator_id",                                            :null => false
    t.integer  "last_modifier_id",                                      :null => false
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_canceled",                    :default => false,     :null => false
    t.boolean  "is_expired",                     :default => false,     :null => false
    t.string   "event_type",       :limit => 25, :default => "general"
    t.integer  "conference_id"
    t.string   "room"
  end

  add_index "events", ["conference_id"], :name => "conference_ndx"
  add_index "events", ["event_type"], :name => "event_type_ndx"
  add_index "events", ["room"], :name => "room_ndx"

  create_table "learner_activities", :force => true do |t|
    t.integer  "learner_id",   :null => false
    t.integer  "recipient_id", :null => false
    t.integer  "activity",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "learner_activities", ["learner_id", "recipient_id", "activity"], :name => "learner_activity_ndx"

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
    t.string   "bio"
    t.string   "avatar"
    t.boolean  "has_profile",                        :default => false, :null => false
    t.integer  "darmok_id"
    t.boolean  "retired",                            :default => false, :null => false
    t.boolean  "is_admin",                           :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_blocked",                         :default => false, :null => false
  end

  add_index "learners", ["darmok_id"], :name => "index_learners_on_darmok_id"
  add_index "learners", ["email"], :name => "index_learners_on_email"

  create_table "mailer_caches", :force => true do |t|
    t.string   "hashvalue",      :limit => 40,                      :null => false
    t.integer  "learner_id"
    t.integer  "cacheable_id"
    t.string   "cacheable_type", :limit => 30
    t.integer  "open_count",                         :default => 0
    t.text     "markup",         :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mailer_caches", ["hashvalue"], :name => "hashvalue_ndx"
  add_index "mailer_caches", ["learner_id", "open_count"], :name => "open_learner_ndx"

  create_table "notification_exceptions", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "event_id"
    t.datetime "created_at"
  end

  add_index "notification_exceptions", ["learner_id", "event_id"], :name => "connection_ndx", :unique => true

  create_table "notifications", :force => true do |t|
    t.integer  "notifiable_id"
    t.string   "notifiable_type",  :limit => 30
    t.boolean  "processed",                      :default => false, :null => false
    t.integer  "notificationtype",                                  :null => false
    t.datetime "delivery_time",                                     :null => false
    t.integer  "offset",                         :default => 0
    t.integer  "delayed_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portfolio_settings", :force => true do |t|
    t.text     "currently_learning"
    t.text     "learning_plan"
    t.integer  "learner_id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portfolio_settings", ["learner_id"], :name => "index_portfolio_settings_on_learner_id", :unique => true

  create_table "preferences", :force => true do |t|
    t.integer  "prefable_id"
    t.string   "prefable_type", :limit => 30
    t.string   "group"
    t.string   "name",                        :null => false
    t.string   "datatype"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["group"], :name => "index_preferences_on_group"
  add_index "preferences", ["prefable_id", "prefable_type", "name"], :name => "pref_uniq_ndx", :unique => true

  create_table "presenter_connections", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "event_id"
    t.datetime "created_at"
  end

  add_index "presenter_connections", ["learner_id", "event_id"], :name => "connection_ndx", :unique => true

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

  add_index "ratings", ["learner_id", "rateable_type", "rateable_id"], :name => "index_ratings_on_learner_id_and_rateable_type_and_rateable_id", :unique => true

  create_table "recommendations", :force => true do |t|
    t.integer  "learner_id"
    t.date     "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommendations", ["learner_id", "day"], :name => "recommendation_ndx"

  create_table "recommended_events", :force => true do |t|
    t.integer  "recommendation_id"
    t.integer  "event_id"
    t.boolean  "viewed",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommended_events", ["recommendation_id", "event_id"], :name => "recommended_event_ndx"

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

  create_table "versions", :force => true do |t|
    t.string   "item_type",                          :null => false
    t.integer  "item_id",                            :null => false
    t.string   "event",                              :null => false
    t.string   "whodunnit"
    t.string   "ipaddress"
    t.text     "object",         :limit => 16777215
    t.text     "object_changes", :limit => 16777215
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
