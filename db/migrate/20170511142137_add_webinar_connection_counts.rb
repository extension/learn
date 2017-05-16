class AddWebinarConnectionCounts < ActiveRecord::Migration
  def change
    add_column(:zoom_webinars, :registered_count, :integer, :default => 0)
    add_column(:zoom_webinars, :attended_count, :integer, :default => 0)
  end
end
