class Authmap < ActiveRecord::Base
  devise :omniauthable
  belongs_to :learner
  validates :authname, :uniqueness => {:scope => :source}


  def self.find_for_twitter_oauth(access_token, logged_in_learner=nil)
    return process_learner_info(access_token, logged_in_learner)
  end

  def self.find_for_facebook_oauth(access_token, logged_in_learner=nil)
    return process_learner_info(access_token, logged_in_learner)
  end

  def self.find_for_people_openid(access_token, logged_in_learner=nil)
    return process_learner_info(access_token, logged_in_learner)
  end

  def self.find_for_google_oauth(access_token, logged_in_learner=nil)
    return process_learner_info(access_token, logged_in_learner)
  end

  # UPDATE: Will handle account merges manually (through a call from the console to the merge_account_with method on the learner model)
  # on a case by case basis for now
  # TODO: Logic needs to be changed here for account merge
  def self.process_learner_info(provider, access_token, logged_in_learner)
    if !logged_in_learner.blank?
      return logged_in_learner
    end

    learner_screen_name = access_token['uid']
    learner_provider = access_token['provider']

    if authmap = Authmap.where({:authname => learner_screen_name, :source => learner_provider}).first
      return authmap.learner
    elsif(access_token['info']['email'].present? and (authmap = Authmap.where({:email => learner_screen_name, :source => learner_provider}).first))
      # really a special case to match the email for google openid to oauth changeover
      return authmap.learner
    end

    # search for an existing learner and match the email.
    if(access_token['info']['email'].present? and learner = Learn.where(email: access_token['info']['email']).first)
      learner.authmaps << self.new(:authname => learner_screen_name, :source => learner_provider)
      learner.save
      learner
    else
      new_learner = Learner.create
      new_learner.email = access_token['info']['email'] if access_token['info']['email'].present?
      new_learner.name = access_token['info']['name'] if access_token['info']['name'].present?
      new_learner.authmaps << self.new(:authname => learner_screen_name, :source => learner_provider)
      new_learner.save
      new_learner
    end
  end

end
