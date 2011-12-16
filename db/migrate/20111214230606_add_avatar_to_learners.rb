class AddAvatarToLearners < ActiveRecord::Migration
  def change
    add_column :learners, :avatar, :string
  end
end
