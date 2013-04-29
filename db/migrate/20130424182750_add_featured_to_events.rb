class AddFeaturedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :featured, :boolean, :default => false, :null => false
    add_column :events, :featured_at, :datetime
  end
end
