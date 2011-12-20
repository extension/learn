$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require 'yaml'
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require "airbrake/capistrano"
require "delayed/recipes"  

#------------------------------
# <i>Should</i> only have to edit these three vars for standard eXtension deployments

set :application, "learn"
set :user, 'pacecar'
set :localuser, ENV['USER']
set :rvm_ruby_string, '1.9.3'
set :port, 24
#------------------------------

set :repository, "git@github.com:extension/#{application}.git"
set :use_sudo, false
set :scm, :git
set :migrate_target, :latest
set :rails_env, "production" #added for delayed job  

# Make sure environment is loaded as first step
on :load, "deploy:setup_environment"

# Disable our app before running the deploy
before "deploy", "deploy:web:disable"
before "deploy", "delayed_job:stop"
before "db:rebuild", "deploy:web:disable"
before "db:rebuild", "delayed_job:stop"

# After code is updated, do some house cleaning
after "deploy:update_code", "deploy:bundle_install"
after "deploy:update_code", "deploy:update_maint_msg"
after "deploy:update_code", "deploy:link_configs"
after "deploy:update_code", "deploy:cleanup"
after "deploy:update_code", "deploy:assets"
after "deploy:update_code", "deploy:migrate"

# don't forget to turn it back on
after "deploy", "delayed_job:start"
after "deploy", "deploy:web:enable"
after "deploy", 'deploy:notification:email'
after "db:rebuild", "deploy:restart"
after "db:rebuild", "delayed_job:start"
after "db:rebuild", "deploy:web:enable"

 namespace :deploy do
   
   # Read in environment settings and setup appropriate repository and
   # deployment settings.  After this is run you can expect all roles,
   # deploy dirs and repository variables to be properly set.
   task :setup_environment do

     # Make sure all necessary roles are defined, the repository location
     # is determined, and the deploy dir is set
     if(server_settings)
       setup_roles
       set :deploy_to, server_settings['deploy_dir']
       if(ENV['SERVER'] == 'demo')
         if(ENV['REBUILD'] == 'true' or ENV['REBUILD'] == 'TRUE')
           after "deploy:update_code", "db:rebuild"
         end
         if(branch = ENV['BRANCH'])
           set :branch, branch
         else
           puts "ERROR: a branch name is required when deploying to the #{ENV['SERVER']} server"
           exit
         end
       else
         set :branch, server_settings['branch'] 
       end
       ssh_options[:port] = server_settings['ssh_port'] if server_settings['ssh_port']
       puts "  * Operating on: #{server_settings['host']}:#{deploy_to} from #{repository} as user: #{user}"
     else
       puts "  * WARNING: There is no 'SERVER' environment variable that matches an entry in the deploy_servers.yml file.  This will cause problems if you are attempting to execute a remote command."
     end      
   end
   
   task :start do ; end
   task :stop do ; end
   
   # Override default restart task
     desc "Restart #{application} mod_rails"
     task :restart, :roles => :app do
       run "touch #{current_path}/tmp/restart.txt"
     end
   
   desc "runs bundle update"
     task :bundle_install do
       run "cd #{release_path} && bundle install"
     end
     
     desc "Update maintenance mode page/graphics (valid after an update code invocation)"
     task :update_maint_msg, :roles => :app do
        run "cp -f #{release_path}/public/maintenancemessage.html #{shared_path}/system/maintenancemessage.html"
     end

     desc "clean out the assets and recompile"
     task :assets, :role => :app do
       run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
     end
     
     desc "Link up various configs (valid after an update code invocation)"
     task :link_configs, :roles => :app do
       run <<-CMD
       rm -rf #{release_path}/config/database.yml #{release_path}/index &&
       rm -rf #{release_path}/public/robots.txt &&
       rm -rf #{release_path}/config/settings.local.yml &&
       rm -rf #{shared_path}/cache/* &&
       rm -rf #{release_path}/tmp/temp &&
       rm -rf #{release_path}/tmp/associations &&
       rm -rf #{release_path}/tmp/nonces &&
       rm -rf #{release_path}/public/uploads &&
       ln -nfs #{shared_path}/uploads #{release_path}/public/uploads &&
       ln -nfs #{shared_path}/nonces #{release_path}/tmp/nonces &&
       ln -nfs #{shared_path}/temp #{release_path}/tmp/temp &&
       ln -nfs #{shared_path}/associations #{release_path}/tmp/associations &&
       ln -nfs #{shared_path}/cache #{release_path}/tmp/cache &&
       ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
       ln -nfs #{shared_path}/config/sunspot.yml #{release_path}/config/sunspot.yml &&
       ln -nfs #{shared_path}/config/robots.txt #{release_path}/public/robots.txt &&
       ln -nfs #{shared_path}/config/settings.local.yml #{release_path}/config/settings.local.yml
       CMD
     end
     
       # Override default web enable/disable tasks
     namespace :web do

       desc "Put Apache in maintenancemode by touching the system/maintenancemode file"
       task :disable, :roles => :app do
         run "touch #{shared_path}/system/maintenancemode"
       end

       desc "Remove Apache from maintenancemode by removing the system/maintenancemode file"
       task :enable, :roles => :app do
         run "rm -f #{shared_path}/system/maintenancemode"
       end
     end
     
     # generate an email to notify various users that a new version has been deployed
     namespace :notification do
       desc "Generate an email for the deploy"
       task :email, :roles => [:app] do 
         run "ruby #{release_path}/config/deploynotification.rb -r #{release_path} -a #{application} -h #{server_settings['host']} -u #{localuser} -p #{previous_revision} -l #{latest_revision} -b #{branch}"
       end
     end
     
 end
 
 namespace :db do
   desc "drop the database, create the database, run migrations, seed"
   task :rebuild, :roles => :db, :only => {:primary => true} do
     if ENV['SERVER'] == 'demo' #add check to guard against any chance of rebuilding the prod db 
       run "cd #{deploy_to}/current && #{rake} db:demo_rebuild RAILS_ENV=production"
     else
       puts "ERROR: cap db:rebuild is only supported for the demo server "
       exit
     end 
   end
 end
 
 #--------------------------------------------------------------------------
 # useful administrative routines
 #--------------------------------------------------------------------------

 namespace :admin do

   desc "Open up a remote console to #{application} (be sure to set your RAILS_ENV appropriately)"
   task :console, :roles => :app do
     input = ''
     command = "cd #{current_path} && ./script/rails console #{fetch(:rails_env)}"
     prompt = /:\d{3}:\d+(\*|>)/
     run command do |channel, stream, data|
       next if data.chomp == input.chomp || data.chomp == ''
       print data
       channel.send_data(input = $stdin.gets) if data =~ prompt
     end
   end

   desc "Tail the server logs for #{application}"
   task :tail_logs, :roles => :app do
     run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
       puts  # for an extra line break before the host name
       puts "#{channel[:host]}: #{data}" 
       break if stream == :err    
     end
   end
 end
 
 
 #--------------------------------------------------------------------------
 # Repository URI helper methods - specifically for the eXtension deployment
 # environment and best practices
 #--------------------------------------------------------------------------

 # Setup the app, db and web roles (all currently just point to the
 # same host name)
 def setup_roles
   [:app, :db, :web].each do |role_name|
     role role_name, server_settings['host'], :primary => true
   end
 end

 # Get the server settings specified in ./deploy_servers.yml
 # NOTE: will probably want to allow the user to specify where their
 # deploy_servers.yml file is in the future?
 def server_settings
   @server_settings ||= YAML.load_file('config/deploy_servers.yml')[ENV['SERVER']]
 end
