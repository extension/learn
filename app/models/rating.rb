class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  belongs_to :learner
  has_many :event_activities, :as => :trackable, dependent: :destroy
    
  validates :rateable_id, :rateable_type, :score, :presence => true
  validates :learner_id, :uniqueness => {:scope => [:rateable_id, :rateable_type]}
    
  after_create :log_object_activity

  scope :positive, :conditions => {:score => 1}
  
  def log_object_activity
    EventActivity.log_object_activity(self)
  end
  
  def self.find_or_create_by_params(learner, rating_params)
    return_rating = Rating.where(rateable_type: rating_params[:rateable_type], rateable_id: rating_params[:rateable_id], learner_id: learner.id).first
    if return_rating.blank?
      return_rating = Rating.new(rating_params)
      return_rating.learner = learner
    end
    return return_rating
  end
end
