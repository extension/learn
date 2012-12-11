set :stages, %w(prod dev)
set :default_stage, "dev"
require 'capistrano/ext/multistage'

# # added by capatross generate_config
require 'capatross'
require 'yaml'
require "airbrake/capistrano"

#------------------------------
# <i>Should</i> only have to edit these three vars for standard eXtension deployments

set :application, "learn"
set :user, 'pacecar'
set :localuser, ENV['USER']
set :port, 24
#------------------------------

set :repository, "git@github.com:extension/#{application}.git"
set :use_sudo, false
set :scm, :git
set :migrate_target, :latest
set :rails_env, "production" #added for delayed job

# Disable our app before running the deploy
before "deploy", "deploy:web:disable"
before "deploy:web:disable", "delayed_job:stop"
before "delayed_job:start", "delayed_job:reload"

# After code is updated, do some house cleaning
after "deploy:update_code", "deploy:bundle_install"
after "deploy:update_code", "deploy:update_maint_msg"
after "deploy:update_code", "deploy:link_configs"
after "deploy:update_code", "deploy:cleanup"
#after "deploy:update_code", "deploy:assets"
after "deploy:update_code", "deploy:migrate"

# don't forget to turn it back on
after "deploy", "deploy:web:enable"
after "deploy:web:enable", "delayed_job:start"

 namespace :deploy do

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

     # desc "clean out the assets and recompile"
     # task :assets, :role => :app do
     #   run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
     # end

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

 end

 namespace :delayed_job do
   desc "stops delayed_job"
   task :stop, :roles => :app do
     run "sudo god stop delayed_jobs"
   end

   desc "reloads delayed_job"
   task :reload, :roles => :app do
     run "sudo god load #{current_path}/config/delayed_job.god"
   end

   desc "starts delayed_job"
   task :start, :roles => :app do
     run "sudo god start delayed_jobs"
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
