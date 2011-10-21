# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


class LearnSession < ActiveRecord::Base
  base_config = Session.connection.instance_variable_get("@config")
  base_config[:database] = 'prod_darmok'
  establish_connection(base_config)
end

# direct inject of Sessions to maintain id's

learn_session_db = LearnSession.connection.instance_variable_get("@config")[:database]
Session.connection.execute("INSERT into #{Session.table_name} SELECT * from #{learn_session_db}.#{LearnSession.table_name}")
