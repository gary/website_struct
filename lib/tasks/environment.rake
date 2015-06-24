require "active_record"
require "yaml"

include ActiveRecord::Tasks

DatabaseTasks.env  = "development"
DatabaseTasks.root = __dir__
DatabaseTasks.db_dir = "db"
DatabaseTasks.migrations_paths = [File.join(DatabaseTasks.db_dir, "migrate")]
DatabaseTasks.database_configuration = YAML.load_file("config/database.yml")

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.
    establish_connection(ENV["WEBSITE_STRUCT_ENV"] || "development")
end
