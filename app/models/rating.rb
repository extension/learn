class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  belongs_to :learner
  
  validates :rateable_id, :rateable_type, :score, :presence => true
  
  scope :positive, :conditions => {:score => 1}
  
  def self.find_or_create_by_params(learner, rating_params)
    return_rating = learner.ratings.where(rateable_type: rating_params[:rateable_type], rateable_id: rating_params[:rateable_id]).first
    if !return_rating.blank?
      return_rating.score = rating_params[:score]
    else
      return_rating = Rating.new(rating_params)
      return_rating.creator = learner
    end
    return return_rating
  end
end
