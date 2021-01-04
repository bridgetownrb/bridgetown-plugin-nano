module BridgetownPluginNano
  module Commands
    class Nano < Thor
      module DatabaseHelpers
        def setup_postgresql
          template "databases/postgresql.yml", "#{folder_name}/config/database.yml"
  
          create_file "#{folder_name}/db/.keep", ""
  
          append_to_file "Gemfile" do
            <<~RUBY
  
              if ENV["RAILS_ENV"]
                gem "pg"
              end
            RUBY
          end
        end

        def finish_database_setup
          copy_file "databases/application_record.rb",
                    "#{folder_name}/app/models/application_record.rb"

          inject_into_file "#{folder_name}/config/application.rb",
                           "require \"active_record/railtie\"\n",
                           after: "require \"action_controller/railtie\"\n"

          say_status :nano, "Database configuration complete!"
          say_status :nano, "You will need a RAILS_ENV environment variable set,"
          say_status :nano, "then run `bundle install`."
          say_status :nano, "Afterwards, you can now run commands like" \
                            " `bridgetown nano exec db:setup` to create your database."
        end
      end
    end
  end
end
