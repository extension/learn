# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class MailerCache < ActiveRecord::Base
  belongs_to :learner
  belongs_to :cacheable, :polymorphic => true
  has_many :activity_logs, :as => :loggable, dependent: :destroy
  
  before_create :generate_hashvalue
  
  def generate_hashvalue
    randval = rand
    self.hashvalue = Digest::SHA1.hexdigest(Settings.session_token+self.learner_id.to_s+randval.to_s)
  end
end
