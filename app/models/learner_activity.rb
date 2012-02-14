class LearnerActivity < ActiveRecord::Base
  belongs_to :learner
  belongs_to :recipient, :class_name => 'Learner'
  has_many :activity_logs, :as => :loggable, dependent: :destroy
  validates :learner_id, :recipient_id, :activity, :presence => true

  BLOCKED = 1
  UNBLOCKED = 2
  
  ACTIVITY_MAP = {
    1   => "blocked",
    2   => "unblocked"
  }
  
  
  def create_activity_log(additional_information)
    self.activity_logs.create(learner: self.learner, additional: additional_information)
  end
  
  def self.log_block(learner, recipient)
    self.create_with_activity_log({learner: learner, recipient: recipient, activity: BLOCKED})
  end
  
  def self.log_unblock(learner, recipient)
    self.create_with_activity_log({learner: learner, recipient: recipient, activity: UNBLOCKED})
  end
  
  def self.create_with_activity_log(attributes, additional_information = nil)
    record = self.create(attributes)
    record.create_activity_log(additional_information)  
  end

end
