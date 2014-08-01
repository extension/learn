set :deploy_to, "/services/learn/"
set :branch, 'master'
set :vhost, 'learn.extension.org'
server vhost, :app, :web, :db, :primary => true
