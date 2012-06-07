set :deploy_to, "/services/apache/vhosts/demo.learn.extension.org/railsroot/"
if(branch = ENV['BRANCH'])
  set :branch, branch
else
  set :branch, 'staging'
end
server 'demo.learn.extension.org', :app, :web, :db, :primary => true
