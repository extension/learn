set :deploy_to, "/services/learn/"
if(branch = ENV['BRANCH'])
  set :branch, branch
else
  set :branch, 'master'
end
set :vhost, 'dev-learn.extension.org'
set :deploy_server, 'dev-learn.awsi.extension.org'
server deploy_server, :app, :web, :db, :primary => true
