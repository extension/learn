# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :events, :through => :taggings, :source => :taggable, :source_type => 'Event'
  
  validates :name, :presence => true, :uniqueness => true

  scope :used_at_least_once, -> { joins(:taggings).group("tags.id").having("COUNT(taggings.id) > 0").select("tags.*, COUNT(taggings.id) AS tag_count") }
  scope :not_used, -> { includes(:taggings).group("tags.id").having("COUNT(taggings.id) = 0") }
  
  SPLITTER = Regexp.new(%r{\s*,\s*})
  JOINER = ", "
  
  # normalize tag names 
  # convert whitespace to single space, underscores to space, yank everything that's not alphanumeric : - or whitespace (which is now single spaces)   
  def self.normalizename(name)
    # make an initial downcased copy - don't want to modify name as a side effect
    returnstring = name.downcase
    # now, use the replacement versions of gsub and strip on returnstring
    # convert underscores to spaces
    returnstring.gsub!('_',' ')
    # get rid of anything that's not a "word", not space, not : and not - 
    returnstring.gsub!(/[^\w :-]/,'')
    # reduce multiple spaces to a single space
    returnstring.gsub!(/ {2,}/,' ')
    # remove leading and trailing whitespace
    returnstring.strip!
    returnstring
  end
  
  def self.find_or_create_by_normalizedname(name)
    Tag.find_or_create_by_name(Tag.normalizename(name))
  end
  
end
