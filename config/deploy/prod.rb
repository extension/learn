set :deploy_to, "/services/apache/vhosts/learn.extension.org/railsroot/"
set :branch, 'master'
server 'learn.extension.org', :app, :web, :db, :primary => true