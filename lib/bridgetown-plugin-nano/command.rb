require_all "bridgetown-core/commands/concerns"

module BridgetownPluginNano
  module Commands
    class Nano < Thor
      include Thor::Actions
      include Bridgetown::Commands::ConfigurationOverridable

      attr_reader :folder_name, :database_prefix

      Bridgetown::Commands::Registrations.register do
        desc "nano <command>", "Install or interact with the Nano backend"
        subcommand "nano", Nano
      end

      def self.source_root
        File.expand_path("templates", __dir__)
      end

      desc "new [NAME optional]", 'Install a new Nano backend into the destination subfolder (default "backend") of the Bridgetown site'
      def new(folder_name = "backend")
        @folder_name = folder_name
        self.destination_root = File.expand_path(folder_name)

        say_status :nano, %(Setting up Nano in "#{folder_name}")
        directory "new_app", ".", exclude_pattern: %r!DS_Store$!

        self.destination_root = File.expand_path(".")

        template "bridgetown_root/config.ru", "config.ru"
        copy_file "bridgetown_root/Rakefile", "Rakefile"

        gsub_file "start.js", 'sleep 4; yarn serve --port " + port', 'sleep 4; bundle exec rake nano:start -- --port=" + port'
        gsub_file "webpack.config.js", %(const path = require("path");\n), %(const path = require("path");\nconst webpack = require("webpack");\n)
        inject_into_file "webpack.config.js", <<-JS, after: "\n  plugins: [\n"
    new webpack.DefinePlugin({
      NANO_API_URL: JSON.stringify(process.env.NANO_API_URL || "")
    }),
        JS

        append_to_file "Gemfile" do
          <<~RUBY

            # Gems required by the Nano backend:
            gem "dotenv"
            gem "puma"
            gem "rails"
            gem "rack-cors"
          RUBY
        end
        Bridgetown.with_unbundled_env do
          run "bundle install", abort_on_failure: true
        end

        logger = Bridgetown.logger
        logger.info ""
        logger.info "Success!".green, "🎉 Your Nano backend was" \
                    " generated in #{folder_name.cyan}."
      end

      desc "database TYPE:PREFIX", 'Configure a database (types: "postgresql") and use prefix in database name'
      def database(type_prefix)
        dbtype, @database_prefix = type_prefix.split(':')

        determine_folder_name

        case dbtype
        when "postgresql"
          setup_postgresql
        else
          raise "The #{dbtype} database type is not supported"
        end

        copy_file "databases/application_record.rb", "#{folder_name}/app/models/application_record.rb"

        inject_into_file "#{folder_name}/config/application.rb", "require \"active_record/railtie\"\n", after: "require \"action_controller/railtie\"\n"

        say_status :nano, "Database configuration complete!"
        say_status :nano, "You will need a RAILS_ENV environment variable set,"
        say_status :nano, "then run `bundle install`."
        say_status :nano, "Afterwards, you can now run commands like" \
                          " `bridgetown nano exec db:setup` to create your database."
      end

      desc "exec", "Execute any Rails subcommand"
      def exec(*arg)
        determine_folder_name
        system("cd #{folder_name} && bundle exec rails #{args.join(" ")}")
      end

      desc "console", "Rails console"
      def console
        determine_folder_name
        system("cd #{folder_name} && bundle exec rails console")
      end

      desc "generate", "Rails generator"
      def generate(*args)
        determine_folder_name
        system("cd #{folder_name} && bundle exec rails generate #{args.join(" ")}")
      end

      private

      def determine_folder_name
        rackfile = File.read("config.ru")
        matches = %r(require_relative "\./(.*?)/config/application").match(rackfile)
        if matches
          @folder_name = matches[1]
        else
          raise "Nano backend folder could not be determined. Is there an" \
                "appropriate require_relative statement in your config.ru file?"
        end
      end

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
    end
  end
end