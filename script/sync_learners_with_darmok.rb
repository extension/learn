# encoding: UTF-8
# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

@mydatabase = ActiveRecord::Base.connection.instance_variable_get("@config")[:database]
@darmokdatabase = Settings.darmokdatabase

# routines
def update_learners_from_darmok_accounts
  account_insert_query = <<-END_SQL.gsub(/\s+/, " ").strip
  UPDATE #{@mydatabase}.learners, #{@darmokdatabase}.accounts
  SET #{@mydatabase}.learners.name=concat_ws(' ',#{@darmokdatabase}.accounts.first_name, #{@darmokdatabase}.accounts.last_name),
      #{@mydatabase}.learners.retired=#{@darmokdatabase}.accounts.retired,
      #{@mydatabase}.learners.is_admin=#{@darmokdatabase}.accounts.is_admin,
      #{@mydatabase}.learners.email=#{@darmokdatabase}.accounts.email,
      #{@mydatabase}.learners.time_zone = #{@darmokdatabase}.accounts.time_zone
  WHERE #{@mydatabase}.learners.darmok_id = #{@darmokdatabase}.accounts.id AND #{@darmokdatabase}.accounts.vouched=1
  END_SQL
  Learner.connection.execute(account_insert_query)
  
end

def transfer_accounts
  # import all non-retired/"valid" accounts
  account_insert_query = <<-END_SQL.gsub(/\s+/, " ").strip
  INSERT IGNORE INTO #{@mydatabase}.#{Learner.table_name} (name, email, has_profile, time_zone, darmok_id, is_admin, created_at, updated_at) 
    SELECT CONCAT(#{@darmokdatabase}.accounts.first_name,' ', #{@darmokdatabase}.accounts.last_name), #{@darmokdatabase}.accounts.email, 1, 
           #{@darmokdatabase}.accounts.time_zone, #{@darmokdatabase}.accounts.id, #{@darmokdatabase}.accounts.is_admin, #{@darmokdatabase}.accounts.created_at, NOW()
    FROM  #{@darmokdatabase}.accounts
    WHERE #{@darmokdatabase}.accounts.retired = 0 and #{@darmokdatabase}.accounts.vouched = 1
  END_SQL
  Learner.connection.execute(account_insert_query)

  authmap_insert_query = <<-END_SQL.gsub(/\s+/, " ").strip
  INSERT IGNORE INTO #{@mydatabase}.#{Authmap.table_name} (learner_id, authname, source, created_at, updated_at) 
    SELECT #{@mydatabase}.learners.id, CONCAT('https://people.extension.org/',#{@darmokdatabase}.accounts.login), 'people', #{@darmokdatabase}.accounts.created_at, NOW()
    FROM #{@mydatabase}.learners,#{@darmokdatabase}.accounts
    WHERE #{@mydatabase}.learners.darmok_id = #{@darmokdatabase}.accounts.id
  END_SQL
  Authmap.connection.execute(authmap_insert_query)

end

# let's do this
 
puts "Updating accounts..."
benchmark = Benchmark.measure do
  update_learners_from_darmok_accounts
end
puts " Accounts updated : #{benchmark.real.round(2)}s"

puts "Transferring accounts..."
benchmark = Benchmark.measure do
  transfer_accounts
end
puts " Accounts transferred : #{benchmark.real.round(2)}s"

