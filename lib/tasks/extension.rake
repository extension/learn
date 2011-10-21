# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
namespace :db do
  desc "(local dev) Drop:all, create, migrate, seed the database"
  task :rebuild => ['db:drop:all', 'db:create', 'db:migrate', 'db:seed']
  
  desc "(demo) drop, create, migrate, seed"
  task :demo_rebuild => ['db:drop', 'db:create', 'db:migrate', 'db:seed']
end