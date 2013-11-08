set :deploy_to, "/services/learn/"
set :branch, 'master'
server 'learn.extension.org', :app, :web, :db, :primary => true
