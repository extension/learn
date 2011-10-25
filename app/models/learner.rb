class Learner < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name 
  
  has_many :ratings
  has_many :authmaps
end
