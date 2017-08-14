class CleanupUnusedItems < ActiveRecord::Migration
  def up
    drop_table(:conferences)
    drop_table(:conference_connections)
    drop_table(:evaluation_questions)
    drop_table(:evaluation_answers)
    drop_table(:stock_questions)
    drop_table(:questions)
    drop_table(:answers)
    drop_table(:ratings)

    remove_column(:events, :conference_id)
    remove_column(:events, :room)
  end

  def down
  end
end
