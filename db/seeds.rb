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

@darmokdatabase = 'prod_darmok'
@mydatabase = ActiveRecord::Base.connection.instance_variable_get("@config")[:database]

class LearnSession < ActiveRecord::Base
  base_config = ActiveRecord::Base.connection.instance_variable_get("@config")
  base_config[:database] = @darmokdatabase
  establish_connection(base_config)
end


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

# reindex Events in solr
Event.reindex