class Learner < ActiveRecord::Base
  devise :rememberable, :trackable

  # Setup accessible (or protected) attributes
  attr_accessible :email, :remember_me, :name 
  
  has_many :ratings
  has_many :authmaps
end
