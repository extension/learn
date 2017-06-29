class DisambiguizeCounters < ActiveRecord::Migration
  def change
    rename_column(:events, :bookmarks_count, :followers_count)
    rename_column(:events, :attended_count, :attendees_count)
    # remove raters, events can't be rated any longer
    remove_column(:events, :raters_count)
  end

  def down
  end
end
