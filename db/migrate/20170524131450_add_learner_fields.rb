class AddLearnerFields < ActiveRecord::Migration
  def up
    add_column(:learners, :openid, :string, :null => true)
    add_column(:learners, :institution_id, :integer, :null => true)
    add_column(:learners, :last_activity_at, :datetime, :null => true)

    # set openid from authmaps
    execute "UPDATE learners,authmaps set learners.openid = authmaps.authname where authmaps.source = 'people' and authmaps.learner_id = learners.id"
    execute "UPDATE learners set last_activity_at = current_sign_in_at where 1"

  end

  def down
  end
end
