set :deploy_to, "/services/learn/"
if(branch = ENV['BRANCH'])
  set :branch, branch
else
  set :branch, 'master'
end
server 'dev.learn.extension.org', :app, :web, :db, :primary => true
