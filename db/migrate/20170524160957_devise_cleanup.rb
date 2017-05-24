class DeviseCleanup < ActiveRecord::Migration
  def up
    drop_table(:authmaps)
    remove_column(:learners, :encrypted_password)
    remove_column(:learners, :remember_created_at)
    remove_column(:learners, :sign_in_count)
    remove_column(:learners, :current_sign_in_at)
    remove_column(:learners, :last_sign_in_at)
    remove_column(:learners, :current_sign_in_ip)
    remove_column(:learners, :last_sign_in_ip)
  end

end
