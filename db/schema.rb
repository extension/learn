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

ActiveRecord::Schema.define(:version => 20111024194056) do

  create_table "authmaps", :force => true do |t|
    t.integer  "learner_id", :null => false
    t.string   "authname",   :null => false
    t.string   "source",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authmaps", ["authname", "source"], :name => "index_authmaps_on_authname_and_source", :unique => true
  add_index "authmaps", ["learner_id"], :name => "index_authmaps_on_learner_id"

  create_table "events", :force => true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "learners", :force => true do |t|
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "time_zone"
    t.string   "email"
    t.boolean  "has_profile",         :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "learners", ["email"], :name => "index_learners_on_email"

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
