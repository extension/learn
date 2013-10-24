class CreateMaterialLinks < ActiveRecord::Migration
  def change
    create_table :material_links do |t|
      t.string :reference_link, null: false
      t.string :description, null: true
      t.integer :event_id, null: false
      t.timestamps
    end
  end
end
