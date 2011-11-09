class CreateLearners < ActiveRecord::Migration
  def change
    create_table(:learners) do |t|
      # creates :email (string) 
      # creates :encrypted_password field (string) 
      # we are letting these fields be null to cover certain cases of scientist records like twitter authentication via oauth
      # that does not give us an email address and we're not storing a pw for it
      t.database_authenticatable :null => true
      # does not create :remember_token(string), not sure why right now, default is supposed to create it
      # creates :remember_created_at(Datetime)
      t.rememberable
      # creates :sign_in_count (Integer)
      # creates :current_sign_in_at (Datetime)
      # creates :last_sign_in_at (Datetime)
      # creates :current_sign_in_ip (string)
      # creates :last_sign_in_ip (string)
      t.trackable
      t.string :name, :time_zone, :mobile_number, :null => true
      t.boolean :has_profile, :null => false, :default => false
      t.integer :darmok_id
      t.boolean :retired, :null => false, :default => false
      t.timestamps
    end
    
    add_index :learners, :email
  end
end
