class AddZoomWebinars < ActiveRecord::Migration
  def change

    create_table "zoom_webinars" do |t|
      t.references :event
      t.integer    "webinar_id", :null => false
      t.integer    "webinar_type"
      t.boolean    "recurring"
      t.boolean    "has_registration_url"
      t.boolean    "last_api_success"
      t.datetime   "webinar_created_at"
      t.text       "uuidlist"
      t.text       "webinar_info",  :limit => 16777215
      t.datetime   "created_at"
  	end

    add_index "zoom_webinars", ["event_id"], :name => "event_ndx"
    add_index "zoom_webinars", ["webinar_id"], :name => "webinar_id_ndx", :unique => true

    add_column(:events, :location_webinar_id, :integer, :null => true)
    add_column(:events, :zoom_webinar_id, :integer, :null => true)
    add_column(:events, :zoom_webinar_status, :integer, :null => true)

    # event_connections table changes
    add_column(:event_connections, :added_by_api, :boolean, default: false)

    create_table "zoom_connections" do |t|
      t.references :zoom_webinar
      t.references :event
      t.references :learner
      t.references :event_connection
      t.string   "zoom_uuid"
      t.string   "zoom_user_id"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "email",           :null => false
      t.boolean  "panelist",        :default => false
      t.boolean  "registered",        :default => false
      t.boolean  "attended",        :default => false
      t.integer  "time_in_session"
      t.text     "additionaldata",  :limit => 16777215
      t.datetime "registered_at",   :null => true
      t.datetime "attended_at",   :null => true
      t.timestamps
  	end

    add_index "zoom_connections", ["email", "zoom_webinar_id"], :name => "registration_ndx", :unique => true
    add_index "zoom_connections", ["zoom_webinar_id","event_id","learner_id","email","registered_at","attended"], :name => "reporting_ndx"

    create_table "zoom_api_logs" do |t|
      t.integer  "webinar_id"
      t.integer  "response_code"
      t.string   "endpoint"
      t.boolean  "json_error"
      t.boolean  "zoom_error"
      t.string   "zoom_error_code"
      t.string   "zoom_error_message"
      t.text     "requestparams"
      t.text     "additionaldata",  :limit => 16777215
      t.datetime "created_at"
  	end

  end

end
