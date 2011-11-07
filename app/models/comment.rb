class Comment < ActiveRecord::Base
  belongs_to :learner
  belongs_to :event
  has_many :ratings, :as => :rateable, :dependent => :destroy
  has_many :raters, :through => :ratings, :source => :learner
  belongs_to :creator, :class_name => 'Learner', :foreign_key => 'learner_id'
  after_create :log_object_activity

  
  # make sure to keep this callback ahead of has_ancestry, which has its own callbacks for destroy
  before_destroy :set_orphan_flag_on_children
  
  # using the ancestry gem for threaded comments
  # orphan strategy will move the parent's children up a level in the hierarchy if the parent gets deleted
  has_ancestry :orphan_strategy => :rootify
  
  validates :content, :learner_id, :event_id, :presence => true
  
  def log_object_activity
    ActivityLog.log_object_activity(self)
  end
  
  def set_orphan_flag_on_children
    self.children.update_all(parent_removed: true)
  end
  

  
end