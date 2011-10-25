class Authmap < ActiveRecord::Base
  devise :omniauthable
  belongs_to :learner
  validates :authname, :uniqueness => {:scope => :source}
  
  def self.find_for_twitter_oauth(access_token, logged_in_learner=nil)
    if !logged_in_learner.blank?
      return logged_in_learner
    end
    
    learner_screen_name = access_token['extra']['user_hash']['screen_name']
    learner_provider = access_token['provider']
    
    if authmap = Authmap.where({:authname => learner_screen_name, :source => learner_provider}).first
      return authmap.learner
    end
    
    new_authmap = self.new(:authname => learner_screen_name, :source => learner_provider)
    
    # TODO: need to handle the case if they're not logged in, and no authmap for twitter has been created yet, and a scientist record does exist, 
    # they would need to login to associate it with their current account or another scientist record will be created
    new_learner = Learner.create
    new_learner.authmaps << new_authmap
    new_learner.save
    return new_learner
  end
end
