class CleanupEventActivitiesAndMore < ActiveRecord::Migration
  def up
    # cleanup views
    execute "DELETE FROM event_activities where activity IN (1,2,3)"

    # cleanup answers, ratings, comments which are no longer in the application
    execute "DELETE FROM event_activities where activity IN (21,31,32,41,42)"

    # clean out now orphaned activity_logs
    execute "DELETE activity_logs.* FROM activity_logs left join event_activities on activity_logs.loggable_id = event_activities.id WHERE activity_logs.loggable_type = 'EventActivity' and event_activities.id is NULL "

    # drop comments
    drop_table(:comments)
    remove_column(:events, :commentators_count)


    # clear out comment preference
    execute "DELETE FROM preferences where name = 'sharing.events.commented'"

    # drop old events_cleanup table
    drop_table('events_cleanup')

    # remove all email open views
    ActivityLog.where(loggable_type: 'MailerCache').delete_all

  end

end
