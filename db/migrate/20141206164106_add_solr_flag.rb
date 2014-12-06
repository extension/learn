class AddSolrFlag < ActiveRecord::Migration
  def change
    add_column :learners, :needs_search_update, :boolean
    add_index :learners, :needs_search_update, :name => 'search_update_flag_ndx'
  end
end
