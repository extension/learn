class FixPrefNaming < ActiveRecord::Migration
  def up
    execute "UPDATE preferences SET name='sharing.events.followed' where name = 'sharing.events.bookmarked'"
  end
end
