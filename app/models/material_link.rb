class MaterialLink < ActiveRecord::Base
  attr_accessible :reference_link, :description, :event_id
  
  belongs_to :event
  validates :description, :reference_link, :presence => true
  validates :event_id, presence: true, on: :update
  validates :reference_link, :uri => true
end
