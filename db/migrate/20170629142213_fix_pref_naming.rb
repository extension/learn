class FixPrefNaming < ActiveRecord::Migration
  def up
    execute "UPDATE preferences SET name='sharing.events.followed' where name = 'sharing.events.bookmarked'"
    execute "UPDATE preferences SET name='sharing.events.viewed' where name = 'sharing.events.watched'"
  end
end
