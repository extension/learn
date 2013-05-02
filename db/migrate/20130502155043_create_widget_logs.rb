class CreateWidgetLogs < ActiveRecord::Migration
  def change
    create_table :widget_logs do |t|
      t.string :referrer_host
      t.string :referrer_url
      t.string :base_widget_url
      t.string :widget_url
      t.string :widget_fingerprint
      t.integer :count, null: false, default: 0
      t.timestamps
    end
  end
end
