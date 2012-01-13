class PortfolioSetting < ActiveRecord::Base
  belongs_to :learner
  validates :learner_id, :presence => true, :uniqueness => true
  
  
end
