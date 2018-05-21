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

ActiveRecord::Schema.define(:version => 20180518144237) do

  create_table "activity_logs", :force => true do |t|
    t.integer  "learner_id",                  :null => false
    t.integer  "loggable_id"
    t.string   "loggable_type", :limit => 30
    t.text     "additional"
    t.datetime "created_at"
  end

  add_index "activity_logs", ["learner_id", "loggable_id", "loggable_type"], :name => "activity_ndx"

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
    t.integer  "connectiontype",                    :null => false
    t.datetime "created_at"
    t.boolean  "added_by_api",   :default => false
  end

  add_index "event_connections", ["learner_id", "event_id", "connectiontype"], :name => "connection_ndx", :unique => true

  create_table "event_registrations", :force => true do |t|
    t.integer  "event_id"
    t.string   "first_name", :default => "", :null => false
    t.string   "last_name",  :default => "", :null => false
    t.string   "email",      :default => "", :null => false
    t.datetime "created_at"
  end

  add_index "event_registrations", ["email", "event_id"], :name => "registration_ndx", :unique => true

  create_table "events", :force => true do |t|
    t.text     "title",                                                        :null => false
    t.text     "description",                                                  :null => false
    t.datetime "session_start",                                                :null => false
    t.datetime "session_end",                                                  :null => false
    t.integer  "session_length",                                               :null => false
    t.text     "location"
    t.text     "recording"
    t.integer  "creator_id",                                                   :null => false
    t.integer  "last_modifier_id",                                             :null => false
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_canceled",                            :default => false,    :null => false
    t.boolean  "is_expired",                             :default => false,    :null => false
    t.string   "event_type",               :limit => 25, :default => "online"
    t.boolean  "featured",                               :default => false,    :null => false
    t.datetime "featured_at"
    t.string   "evaluation_link"
    t.string   "cover_image"
    t.integer  "followers_count",                        :default => 0,        :null => false
    t.integer  "attendees_count",                        :default => 0,        :null => false
    t.integer  "viewers_count",                          :default => 0,        :null => false
    t.text     "provided_presenter_order"
    t.boolean  "is_deleted",                             :default => false,    :null => false
    t.boolean  "requires_registration",                  :default => false,    :null => false
    t.text     "reason_is_deleted"
    t.text     "registration_description"
    t.integer  "primary_audience",                       :default => 0,        :null => false
    t.integer  "location_webinar_id"
    t.integer  "zoom_webinar_id"
    t.integer  "zoom_webinar_status"
    t.boolean  "is_mfln",                                :default => false
  end

  add_index "events", ["event_type"], :name => "event_type_ndx"

  create_table "images", :force => true do |t|
    t.integer  "event_id"
    t.string   "file"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.string   "name"
    t.string   "time_zone"
    t.string   "mobile_number"
    t.string   "bio"
    t.string   "avatar"
    t.boolean  "has_profile",         :default => false, :null => false
    t.integer  "darmok_id"
    t.boolean  "retired",             :default => false, :null => false
    t.boolean  "is_admin",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_blocked",          :default => false, :null => false
    t.boolean  "needs_search_update"
    t.string   "openid"
    t.integer  "institution_id"
    t.datetime "last_activity_at"
  end

  add_index "learners", ["darmok_id"], :name => "index_learners_on_darmok_id"
  add_index "learners", ["email"], :name => "index_learners_on_email"
  add_index "learners", ["needs_search_update"], :name => "search_update_flag_ndx"

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

  create_table "material_links", :force => true do |t|
    t.string   "reference_link", :null => false
    t.string   "description"
    t.integer  "event_id",       :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

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
    t.integer  "position"
  end

  add_index "presenter_connections", ["learner_id", "event_id"], :name => "connection_ndx", :unique => true

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
    t.string   "item_type",                                                   :null => false
    t.integer  "item_id",                                                     :null => false
    t.string   "event",                                                       :null => false
    t.string   "whodunnit",                          :default => "1"
    t.string   "ipaddress",                          :default => "127.0.0.1"
    t.text     "object",         :limit => 16777215
    t.text     "object_changes", :limit => 16777215
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "widget_logs", :force => true do |t|
    t.string   "referrer_host"
    t.text     "referrer_url"
    t.string   "base_widget_url"
    t.string   "widget_url"
    t.string   "widget_fingerprint"
    t.integer  "load_count",         :default => 0, :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "zoom_api_logs", :force => true do |t|
    t.integer  "webinar_id"
    t.integer  "response_code"
    t.string   "endpoint"
    t.boolean  "json_error"
    t.boolean  "zoom_error"
    t.string   "zoom_error_code"
    t.string   "zoom_error_message"
    t.text     "requestparams"
    t.text     "additionaldata",     :limit => 16777215
    t.datetime "created_at"
  end

  create_table "zoom_connections", :force => true do |t|
    t.integer  "zoom_webinar_id"
    t.integer  "event_id"
    t.integer  "learner_id"
    t.integer  "event_connection_id"
    t.string   "zoom_uuid"
    t.string   "zoom_user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                                                      :null => false
    t.boolean  "panelist",                                :default => false
    t.boolean  "registered",                              :default => false
    t.boolean  "attended",                                :default => false
    t.integer  "time_in_session"
    t.text     "additionaldata",      :limit => 16777215
    t.datetime "registered_at"
    t.datetime "attended_at"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
  end

  add_index "zoom_connections", ["email", "zoom_webinar_id"], :name => "registration_ndx", :unique => true
  add_index "zoom_connections", ["zoom_webinar_id", "event_id", "learner_id", "email", "registered_at", "attended"], :name => "reporting_ndx"

  create_table "zoom_webinars", :force => true do |t|
    t.integer  "event_id"
    t.integer  "webinar_id",                                              :null => false
    t.integer  "webinar_type"
    t.boolean  "recurring"
    t.boolean  "has_registration_url"
    t.boolean  "last_api_success"
    t.datetime "webinar_created_at"
    t.datetime "webinar_start_at"
    t.integer  "duration"
    t.text     "uuidlist"
    t.text     "webinar_info",         :limit => 16777215
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "registered_count",                         :default => 0
    t.integer  "attended_count",                           :default => 0
  end

  add_index "zoom_webinars", ["event_id"], :name => "event_ndx"
  add_index "zoom_webinars", ["webinar_id"], :name => "webinar_id_ndx", :unique => true

end
