# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

# clear default task
task default: []
Rake::Task[:default].clear

# set default task to continuous integration
task default: :ci
