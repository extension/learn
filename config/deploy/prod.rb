set :deploy_to, "/services/learn/"
set :branch, 'master'
set :vhost, 'learn.extension.org'
set :deploy_server, 'learn.awsi.extension.org'
server deploy_server, :app, :web, :db, :primary => true
