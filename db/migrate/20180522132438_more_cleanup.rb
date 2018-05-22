class MoreCleanup < ActiveRecord::Migration
  def up
    remove_column(:mailer_caches, :open_count)
    remove_column(:learners, :is_blocked)
    drop_table(:learner_activities)
    ActivityLog.where(loggable_type: 'LearnerActivity').delete_all
  end
end
