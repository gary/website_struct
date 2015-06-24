require "bundler/gem_tasks"
require "rspec/core/rake_task"

load "lib/tasks/environment.rake"
load "active_record/railties/databases.rake"

RSpec::Core::RakeTask.new(:spec)

task default: :spec
