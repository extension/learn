class CreateLearners < ActiveRecord::Migration
  def change
    create_table(:learners) do |t|
      # creates :email (string) 
      # creates :encrypted_password field (string) 
      # we are letting these fields be null to cover certain cases of scientist records
      t.database_authenticatable :null => true
      # creates :reset_password_token(string)
      # creates :reset_password_sent_at(Datetime)
      t.recoverable
      # does not create :remember_token(string), not sure why right now, default is supposed to create it
      # creates :remember_created_at(Datetime)
      t.rememberable
      # creates :sign_in_count (Integer)
      # creates :current_sign_in_at (Datetime)
      # creates :last_sign_in_at (Datetime)
      # creates :current_sign_in_ip (string)
      # creates :last_sign_in_ip (string)
      t.trackable
      # creates :confirmation_token (string)
      # creates :confirmed_at (Datetime)
      # creates :confirmation_sent_at (Datetime)
      t.confirmable
      t.string :name, :time_zone, :null => true
      t.boolean :is_joined, :null => false, :default => false
      
      ### portions of devise we are not using right now ###
      # t.encryptable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      
      t.timestamps
    end
    
    add_index :learners, :email
    add_index :learners, :reset_password_token, :unique => true
    add_index :learners, :confirmation_token,   :unique => true
  end
end
