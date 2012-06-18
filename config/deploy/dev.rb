set :deploy_to, "/services/apache/vhosts/dev.learn.extension.org/railsroot/"
if(branch = ENV['BRANCH'])
  set :branch, branch
else
  set :branch, 'development'
end
server 'dev.learn.extension.org', :app, :web, :db, :primary => true
