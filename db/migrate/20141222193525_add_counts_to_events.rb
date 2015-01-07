class AddCountsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :bookmarks_count, :integer, :default => 0, null: false
    add_column :events, :attended_count, :integer, :default => 0, null: false
    add_column :events, :watchers_count, :integer, :default => 0, null: false
    add_column :events, :raters_count, :integer, :default => 0, null: false
    add_column :events, :commentators_count, :integer, :default => 0, null: false

    Event.reset_column_information

    Event.find_each(select: 'id') do |event|
      Event.update_counters(event.id, :bookmarks_count => event.bookmarks.count)
      Event.update_counters(event.id, :attended_count => event.attended.count)
      Event.update_counters(event.id, :watchers_count => event.watchers.count)
      Event.update_counters(event.id, :raters_count => event.raters.count)
      Event.update_counters(event.id, :commentators_count => event.commentators.count)
  	end
  end

  def self.down
    remove_column :events, :bookmarks_count
    remove_column :events, :attended_count
    remove_column :events, :watchers_count
    remove_column :events, :raters_count
    remove_column :events, :commentators_count
  end
end
