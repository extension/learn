class MaterialLink < ActiveRecord::Base
  attr_accessible :reference_link, :description, :event_id
  
  belongs_to :event
  validates :reference_link, :event_id, :presence => true
end
