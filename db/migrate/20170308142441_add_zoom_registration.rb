class AddZoomRegistration < ActiveRecord::Migration
  def change

    create_table "zoom_registrations" do |t|
      t.references :event
      t.references :learner
      t.references :event_connection
      t.string   "zoom_webinar_id"
      t.string   "zoom_user_id"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "email",           :null => false
      t.boolean  "attended",        :default => false
      t.text     "additionaldata",  :limit => 16777215
      t.datetime "registered_at",   :null => false
      t.timestamps
  	end

    add_index "zoom_registrations", ["email", "event_id"], :name => "registration_ndx", :unique => true
    add_index "zoom_registrations", ["event_id","learner_id","email","registered_at","attended"], :name => "reporting_ndx"

    add_column(:events, :is_zoom_webinar, :boolean)
    add_column(:events, :zoom_webinar_id, :string)

    create_table "zoom_api_logs" do |t|
      t.integer  "request_id"
      t.integer  "response_code"
      t.string   "endpoint"
      t.text     "requestparams"
      t.text     "additionaldata",  :limit => 16777215
      t.datetime "created_at"
  	end

    create_table "event_zoom_requests" do |t|
      t.references :event
      t.string     :request_type
      t.string     :item_count
      t.boolean    :success
      t.datetime   :completed_at
      t.timestamps
  	end

    add_index "event_zoom_requests", ["event_id"], :name => "event_ndx"

  end

end
