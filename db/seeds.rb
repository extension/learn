# encoding: UTF-8
# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

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
@learnbot = Learner.create(email: 'system@extension.org', name: 'Learn System User')

## setup classes and objects that we'll need

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
  
  scope :validaccounts, :conditions => {:retired => false,:vouched => true}
  
  def openid
    "https://people.extension.org/#{self.login}"
  end
  
  def is_validaccount?
    !retired and vouched
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



# routines


def create_account_from_darmok_user(darmok_user)
  ActiveRecord::Base.record_timestamps = false #temporarily turn off magic column updates
  learner = Learner.new
  learner.name = darmok_user.fullname
  learner.email = darmok_user.email
  learner.has_profile = true
  learner.time_zone = darmok_user.time_zone
  learner.retired = !darmok_user.is_validaccount?
  learner.darmok_id = darmok_user.id
  learner.created_at = darmok_user.created_at
  learner.updated_at = Time.now
  learner.save
  # authmap
  learner.authmaps.create(authname: darmok_user.openid, source: 'people', created_at: darmok_user.created_at, updated_at: Time.now)
  ActiveRecord::Base.record_timestamps = true #turning updates back on
  learner
end


def transfer_events
  # direct inject of Events to maintain id's
  transfer_query = <<-END_SQL.gsub(/\s+/, " ").strip
  INSERT into #{Event.table_name} (id,title,description,session_start,session_end,session_length,location,recording,creator_id,last_modifier_id,time_zone,created_at,updated_at)
     SELECT id,title,description,session_start,session_end,session_length,location,recording,created_by,last_modified_by,time_zone,created_at,updated_at from #{@darmokdatabase}.#{LearnSession.table_name}
  END_SQL
  Event.connection.execute(transfer_query)
end 

def scrub_event_descriptions
  Event.all.each do |event|
    # update column avoids validation, callbacks, and timestamp updates
    event.update_column(:description, event.scrub_and_sanitize(event.description))
  end
end

def transfer_event_tags 
  ## tags
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
end

def transfer_accounts

  # import all non-retired/"valid" accounts
  account_insert_query = <<-END_SQL.gsub(/\s+/, " ").strip
  INSERT INTO #{@mydatabase}.#{Learner.table_name} (name, email, has_profile, time_zone, darmok_id, created_at, updated_at) 
    SELECT CONCAT(#{@darmokdatabase}.accounts.first_name,' ', #{@darmokdatabase}.accounts.last_name), #{@darmokdatabase}.accounts.email, 1, 
           #{@darmokdatabase}.accounts.time_zone, #{@darmokdatabase}.accounts.id,  #{@darmokdatabase}.accounts.created_at, NOW()
    FROM  #{@darmokdatabase}.accounts
    WHERE #{@darmokdatabase}.accounts.retired = 0 and #{@darmokdatabase}.accounts.vouched = 1
  END_SQL
  Learner.connection.execute(account_insert_query)

  authmap_insert_query = <<-END_SQL.gsub(/\s+/, " ").strip
  INSERT INTO #{@mydatabase}.#{Authmap.table_name} (learner_id, authname, source, created_at, updated_at) 
    SELECT #{@mydatabase}.learners.id, CONCAT('https://people.extension.org/',#{@darmokdatabase}.accounts.login), 'people', #{@darmokdatabase}.accounts.created_at, NOW()
    FROM #{@mydatabase}.learners,#{@darmokdatabase}.accounts
    WHERE #{@mydatabase}.learners.darmok_id = #{@darmokdatabase}.accounts.id
  END_SQL
  Authmap.connection.execute(authmap_insert_query)

end

def transfer_event_connections

  ## import Learners and create connections
  LearnConnection.all.each do |darmok_learn_connection|
    darmok_user = darmok_learn_connection.user
    if(!(learner = Learner.find_by_email(darmok_user.email)))
      # most likely here due to a retired account
      learner = create_account_from_darmok_user(darmok_user)
    end

    ActiveRecord::Base.record_timestamps = false #temporarily turn off magic column updates    
    if(darmok_learn_connection.connectiontype == LearnConnection::PRESENTER)
      # create a presenter connection
      PresenterConnection.create(event_id: darmok_learn_connection.learn_session_id, learner: learner, 
                                 created_at: darmok_learn_connection.created_at)
    else
      begin 
        # create a bookmark
        EventConnection.create(event_id: darmok_learn_connection.learn_session_id, learner: learner, 
                               connectiontype: darmok_learn_connection.connectiontype, 
                               created_at: darmok_learn_connection.created_at)
      rescue ActiveRecord::RecordNotUnique => e
        # do nothing, dups are coming from presenter bookmarks    
      end
    end
    ActiveRecord::Base.record_timestamps = true #turning updates back on
  end
  
  # fix event_connection timestamps that came from presenter connections
  update_timestamp_query = <<-END_SQL.gsub(/\s+/, " ").strip
  UPDATE #{EventConnection.table_name},#{PresenterConnection.table_name}
   SET #{EventConnection.table_name}.created_at = #{PresenterConnection.table_name}.created_at
   WHERE #{EventConnection.table_name}.event_id = #{PresenterConnection.table_name}.event_id
   AND #{EventConnection.table_name}.learner_id = #{PresenterConnection.table_name}.learner_id
   AND #{EventConnection.table_name}.connectiontype = #{EventConnection::BOOKMARK}
  END_SQL
  EventActivity.connection.execute(update_timestamp_query)
  
  
  # for all the event_activities that were created, set the updated_at
  update_timestamp_query = <<-END_SQL.gsub(/\s+/, " ").strip
  UPDATE #{EventActivity.table_name},#{EventConnection.table_name}
   SET #{EventActivity.table_name}.updated_at = #{EventConnection.table_name}.created_at
   WHERE #{EventActivity.table_name}.trackable_id = #{EventConnection.table_name}.id
   AND #{EventActivity.table_name}.trackable_type = 'EventConnection'
  END_SQL
  EventActivity.connection.execute(update_timestamp_query)

  another_update_timestamp_query = <<-END_SQL.gsub(/\s+/, " ").strip
  UPDATE #{EventActivity.table_name},#{PresenterConnection.table_name}
   SET #{EventActivity.table_name}.updated_at = #{PresenterConnection.table_name}.created_at
   WHERE #{EventActivity.table_name}.trackable_id = #{PresenterConnection.table_name}.id
   AND #{EventActivity.table_name}.trackable_type = 'PresenterConnection'
  END_SQL
  EventActivity.connection.execute(another_update_timestamp_query)
  
  # for all the activity_logs that were created, set the created_at
  update_timestamp_query = <<-END_SQL.gsub(/\s+/, " ").strip
  UPDATE #{ActivityLog.table_name},#{EventActivity.table_name}
   SET #{ActivityLog.table_name}.created_at = #{EventActivity.table_name}.updated_at
   WHERE #{ActivityLog.table_name}.loggable_id = #{EventActivity.table_name}.id
   AND #{ActivityLog.table_name}.loggable_type = 'EventActivity'
  END_SQL
  ActivityLog.connection.execute(update_timestamp_query)
  
end

def transfer_creator_and_modifier
  ## fix creator and last_modifier
  LearnSession.all.each do |darmok_learn_session|
    darmok_creator = darmok_learn_session.creator
    darmok_last_modifier = darmok_learn_session.last_modifier
    if(!(creator = Learner.find_by_email(darmok_creator.email)))
      # most likely here due to a retired account
      learner = create_account_from_darmok_user(darmok_creator)
    end
  
    if(!(last_modifier = Learner.find_by_email(darmok_last_modifier.email)))
      # most likely here due to a retired account
      learner = create_account_from_darmok_user(darmok_last_modifier)
    end
  
    event = Event.find(darmok_learn_session.id)
    event.update_attributes(creator: creator, last_modifier: last_modifier)
  end
end

def index_events
  # reindex Events in solr
  Event.reindex
end  


def create_stock_questions
  StockQuestion.create(active: true, prompt: 'After attending this session, I feel motivated to learn more about this topic.', responsetype: Question::BOOLEAN, responses: ['no','yes'], learner: @learnbot)
  StockQuestion.create(active: true, prompt: 'I wish more of my colleagues would weigh in on the practical applications of the topics covered in this session.', responsetype: Question::SCALE, responses: ['never','always'],    range_start: 1, range_end: 5, learner: @learnbot)
  StockQuestion.create(active: true, prompt: 'I’ll share this information with:', responsetype: Question::MULTIVOTE_BOOLEAN, responses: ['Friends and family.','Colleagues at work.','The people in one or more of my online networks.','No one.'], learner: @learnbot)
end


# let's do this
puts "Transferring events..."
benchmark = Benchmark.measure do
  transfer_events
end
puts " Events transferred : #{benchmark.real.round(2)}s"

puts "Scrubbing event descriptions..."
benchmark = Benchmark.measure do
  scrub_event_descriptions
end
puts " Events descriptions scrubbed : #{benchmark.real.round(2)}s"

puts "Transferring event tags..."
benchmark = Benchmark.measure do
  transfer_event_tags
end
puts " Event tags transferred : #{benchmark.real.round(2)}s"

puts "Transferring accounts..."
benchmark = Benchmark.measure do
  transfer_accounts
end
puts " Accounts transferred : #{benchmark.real.round(2)}s"

puts "Transferring event connections (will take some time)..."
benchmark = Benchmark.measure do
  transfer_event_connections
end
puts " Event connections transferred : #{benchmark.real.round(2)}s"

puts "Transferring event creators/modifiers (will take some time)..."
benchmark = Benchmark.measure do
  transfer_creator_and_modifier
end
puts " Event creator/modifier transferred : #{benchmark.real.round(2)}s"

puts "Indexing events..."
benchmark = Benchmark.measure do
  index_events
end
puts " Events indexed : #{benchmark.real.round(2)}s"

puts "Creating stock questions..."
benchmark = Benchmark.measure do
  create_stock_questions
end
puts " Stock questions created : #{benchmark.real.round(2)}s"


