class CreatePreferences < ActiveRecord::Migration
  def change
    create_table 'preferences' do |t|
      # intentionally not using t.references
      # so that we can limit the size of the type
      # and tighten the index
      t.integer    "prefable_id"
      t.string     "prefable_type", :limit => 30
      t.string     "group"
      t.string     "name", :null => false
      t.string     "datatype"
      t.string     "value"
      t.timestamps
    end
    
    add_index 'preferences', ['prefable_id','prefable_type','name'], :unique => true, :name => 'pref_uniq_ndx'
    add_index 'preferences', ['group']

  end
end
