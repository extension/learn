class AddZoomWebinars < ActiveRecord::Migration
  def change

    # the specific instance of this webinar
    add_column(:events, :zoom_webinar_uuid, :string, :null => true)

    # event_connections table changes
    add_column(:event_connections, :added_by_api, :boolean, default: false)

    create_table "zoom_connections" do |t|
      t.references :zoom_webinar
      t.references :event
      t.references :learner
      t.references :event_connection
      t.string   "zoom_webinar_id"
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

    add_index "zoom_connections", ["email", "event_id"], :name => "registration_ndx", :unique => true
    add_index "zoom_connections", ["event_id","learner_id","email","registered_at","attended"], :name => "reporting_ndx"

    create_table "zoom_api_logs" do |t|
      t.integer  "request_id"
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

    create_table "zoom_event_connection_requests" do |t|
      t.references :event
      t.string     :request_type
      t.boolean    :success
      t.datetime   :completed_at
      t.timestamps
  	end

    add_index "zoom_event_connection_requests", ["event_id"], :name => "event_ndx"

  end

end
