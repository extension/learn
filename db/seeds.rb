# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# test whether a Sunspot server is running
if(!Sunspot.solr_running?)
  puts "ERROR! Unable to seed the database!"
  puts "Solr must be running in order to create and index Knappsack objects"
  puts "Please run solr before continuing - in development this can be done by typing rake sunspot:solr:start.  See rake --tasks for other tasks"
  exit(1)
end

# create a entry 1 "System User"
learnbot = Learner.create(email: 'system@extension.org', name: 'Learn System User')

@mydatabase = ActiveRecord::Base.connection.instance_variable_get("@config")[:database]

class LearnSession < ActiveRecord::Base
  base_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
  base_config[:database] = Settings.darmokdatabase
  establish_connection(base_config)
  has_many :learn_connections
  has_many :users, :through => :learn_connections, :select => "learn_connections.connectiontype as connectiontype, accounts.*"
  
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :last_modifier, :class_name => "User", :foreign_key => "last_modified_by"
  
end

class Account < ActiveRecord::Base
  base_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
  base_config[:database] = Settings.darmokdatabase
  establish_connection(base_config)
  
  DEFAULT_TIMEZONE = 'America/New_York'
  
  
  def fullname 
    return "#{self.first_name} #{self.last_name}"
  end
  
  # override timezone writer/reader
  # returns Eastern by default, use convert=false
  # when you need a timezone string that mysql can handle
  def time_zone(convert=true)
    tzinfo_time_zone_string = read_attribute(:time_zone)
    if(tzinfo_time_zone_string.blank?)
      tzinfo_time_zone_string = DEFAULT_TIMEZONE
    end
      
    if(convert)
      reverse_mappings = ActiveSupport::TimeZone::MAPPING.invert
      if(reverse_mappings[tzinfo_time_zone_string])
        reverse_mappings[tzinfo_time_zone_string]
      else
        nil
      end
    else
      tzinfo_time_zone_string
    end
  end
  
  def time_zone=(time_zone_string)
    mappings = ActiveSupport::TimeZone::MAPPING
    if(mappings[time_zone_string])
      write_attribute(:time_zone, mappings[time_zone_string])
    else
      write_attribute(:time_zone, nil)
    end
  end
end

class User < Account
  
  def openid
    "https://people.extension.org/#{self.login}"
  end
end

class LearnConnection < ActiveRecord::Base
  base_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
  base_config[:database] = Settings.darmokdatabase
  establish_connection(base_config)
  
  belongs_to :learn_session
  belongs_to :user
  
  PRESENTER = 2
  INTERESTED = 3
  ATTENDED = 4
end

@darmokdatabase = Settings.darmokdatabase

# direct inject of Events to maintain id's
Event.connection.execute("INSERT into #{Event.table_name} SELECT * from #{@darmokdatabase}.#{LearnSession.table_name}")

## tag injection

tags_insert_query = <<-END_SQL.gsub(/\s+/, " ").strip
INSERT INTO #{@mydatabase}.#{Tag.table_name}  (name, created_at) 
  SELECT DISTINCT #{@darmokdatabase}.tags.name, #{@darmokdatabase}.tags.created_at 
  FROM #{@darmokdatabase}.tags,#{@darmokdatabase}.taggings
  WHERE #{@darmokdatabase}.taggings.tag_id = #{@darmokdatabase}.tags.id
    AND #{@darmokdatabase}.taggings.taggable_type = 'LearnSession'
END_SQL
Tag.connection.execute(tags_insert_query)

## tagging injection
taggings_insert_query = <<-END_SQL.gsub(/\s+/, " ").strip
INSERT INTO #{@mydatabase}.#{Tagging.table_name} (tag_id, taggable_id, taggable_type, created_at, updated_at) 
  SELECT #{@mydatabase}.tags.id, #{@darmokdatabase}.taggings.taggable_id, 'Event', #{@darmokdatabase}.taggings.created_at, #{@darmokdatabase}.taggings.updated_at
  FROM #{@mydatabase}.tags,#{@darmokdatabase}.tags,#{@darmokdatabase}.taggings
  WHERE #{@darmokdatabase}.taggings.tag_id = #{@darmokdatabase}.tags.id
    AND #{@mydatabase}.tags.name = #{@darmokdatabase}.tags.name
    AND #{@darmokdatabase}.taggings.taggable_type = 'LearnSession'
END_SQL
Tagging.connection.execute(taggings_insert_query)


## import Learners and create connections
LearnConnection.all.each do |darmok_learn_connection|
  darmok_user = darmok_learn_connection.user
  if(!(learner = Learner.find_by_email(darmok_user.email)))
    learner = Learner.new
    learner.name = darmok_user.fullname
    learner.email = darmok_user.email
    learner.has_profile = true
    learner.time_zone = darmok_user.time_zone
    learner.save
    # authmap
    learner.authmaps.create(authname: darmok_user.openid, source: 'people')
  end
  EventConnection.create(event_id: darmok_learn_connection.learn_session_id, learner: learner, connectiontype: darmok_learn_connection.connectiontype)
end

## fix created_by and last_modified_by columns
LearnSession.all.each do |darmok_learn_session|
  darmok_creator = darmok_learn_session.creator
  darmok_last_modifier = darmok_learn_session.last_modifier
  if(!(creator = Learner.find_by_email(darmok_creator.email)))
    creator = Learner.new
    creator.name = darmok_creator.fullname
    creator.email = darmok_creator.email
    creator.has_profile = true
    creator.time_zone = darmok_creator.time_zone
    creator.save
    # authmap
    creator.authmaps.create(authname: darmok_creator.openid, source: 'people')
    
  end
  
  if(!(last_modifier = Learner.find_by_email(darmok_last_modifier.email)))
    last_modifier = Learner.new
    last_modifier.name = darmok_last_modifier.fullname
    last_modifier.email = darmok_last_modifier.email
    last_modifier.has_profile = true
    last_modifier.time_zone = darmok_last_modifier.time_zone
    last_modifier.save
    # authmap
    last_modifier.authmaps.create(authname: darmok_last_modifier.openid, source: 'people')
  end
  
  event = Event.find(darmok_learn_session.id)
  event.update_attributes(creator: creator, last_modifier: last_modifier)
end

# reindex Events in solr
Event.reindex

StockQuestion.create(active: true, prompt: 'After attending this session, I feel motivated to learn more about this topic.', responsetype: Question::BOOLEAN, responses: ['no','yes'], creator: learnbot)
StockQuestion.create(active: true, prompt: 'I wish more of my colleagues would weigh in on the practical applications of the topics covered in this session.', responsetype: Question::SCALE, responses: ['never','always'],  range_start: 1, range_end: 5, creator: learnbot)
StockQuestion.create(active: true, prompt: 'I’ll share this information with:', responsetype: Question::MULTIVOTE_BOOLEAN, responses: ['Friends and family.','Colleagues at work.','The people in one or more of my online networks.','No one.'], creator: learnbot)
