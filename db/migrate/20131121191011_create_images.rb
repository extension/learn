class CreateImages < ActiveRecord::Migration
  def change
      create_table :images do |t|
        t.integer :event_id
        t.string :file

        t.timestamps
      end
    end
end
