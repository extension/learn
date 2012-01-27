class Authmap < ActiveRecord::Base
  devise :omniauthable
  belongs_to :learner
  validates :authname, :uniqueness => {:scope => :source}
  
  # TODO: Logic needs to be changed here for merging of accounts 
  def self.find_for_twitter_oauth(access_token, logged_in_learner=nil)
    if !logged_in_learner.blank?
      return logged_in_learner
    end
    
    learner_screen_name = access_token['extra']['raw_info']['screen_name']
    learner_provider = access_token['provider']
    
    if authmap = Authmap.where({:authname => learner_screen_name, :source => learner_provider}).first
      return authmap.learner
    end
    
    new_authmap = self.new(:authname => learner_screen_name, :source => learner_provider)
    
    # TODO: need to handle the case if they're not logged in, and no authmap for twitter has been created yet, and a learner record does exist, 
    # they would need to login to associate it with their current account or another learner record will be created
    new_learner = Learner.create
    new_learner.authmaps << new_authmap
    new_learner.save
    return new_learner
  end
  
  def self.find_for_people_openid(access_token, logged_in_learner=nil)
    return process_openid_for_learner(access_token, logged_in_learner)
  end
  
  def self.find_for_google_openid(access_token, logged_in_learner=nil)
    return process_openid_for_learner(access_token, logged_in_learner)
  end
  
  def self.process_openid_for_learner(access_token, logged_in_learner)
    if !logged_in_learner.blank?
      return logged_in_learner
    end
    
    learner_screen_name = access_token['uid']
    learner_provider = access_token['provider']
    
    if authmap = Authmap.where({:authname => learner_screen_name, :source => learner_provider}).first
      learner = authmap.learner
      learner.email = access_token['info']['email'] if learner.email.blank?
      learner.name = access_token['info']['name'] if learner.name.blank?
      learner.save if learner.changed?
      return learner
    # if the authmap does not exist for this service, and the email address returned matches an existing learner,
    # add an authmap and associate it with the learner found by the email address 
    elsif learner = Learner.where({:email => access_token['info']['email']}).first
      learner.authmaps << self.new(:authname => learner_screen_name, :source => learner_provider)
      learner.save
      return learner
    end
    
    new_learner = Learner.create({:email => access_token['info']['email'], :name => access_token['info']['name']})
    new_learner.authmaps << self.new(:authname => learner_screen_name, :source => learner_provider)
    new_learner.save
    return new_learner
  end
  
end
