set :deploy_to, "/services/learn/"
if(branch = ENV['BRANCH'])
  set :branch, branch
else
  set :branch, 'master'
end
set :vhost, 'dev-learn.aws.extension.org'
server vhost, :app, :web, :db, :primary => true
set :port, 22
