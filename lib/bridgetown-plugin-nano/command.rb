require_all "bridgetown-core/commands/concerns"

require "bridgetown-plugin-nano/command_helpers/database_helpers"
require "bridgetown-plugin-nano/command_helpers/email_helpers"
require "bridgetown-plugin-nano/command_helpers/general_helpers"
require "bridgetown-plugin-nano/command_helpers/jobs_helpers"

module BridgetownPluginNano
  module Commands
    class Nano < Thor
      include Thor::Actions
      include Bridgetown::Commands::ConfigurationOverridable
      include DatabaseHelpers
      include EmailHelpers
      include GeneralHelpers
      include JobsHelpers

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
        configure_new_nano_app # GeneralHelpers
      end

      desc "about", "Prints information about your Rails configuration"
      def about
        determine_folder_name
        system("cd #{folder_name} && bundle exec rails about")
      end

      desc "database TYPE:PREFIX", 'Configure a database (types: "postgresql") and use prefix in database name'
      def database(type_prefix)
        # NOTE: self.database_prefix is accessed by the YAML template
        dbtype, @database_prefix = type_prefix.split(':')

        determine_folder_name

        case dbtype
        when "postgresql"
          setup_postgresql
        else
          raise "The #{dbtype} database type is not supported"
        end

        finish_database_setup # DatabaseHelpers
      end

      desc "email", "Configure ActionMailer for sending emails"
      def email
        determine_folder_name
        configure_action_mailer
      end

      desc "jobs", "Configure ActiveJob for async background tasks"
      def jobs
        determine_folder_name
        configure_active_job
      end

      desc "exec", "Execute any Rails subcommand"
      def exec(*arg)
        determine_folder_name
        system("cd #{folder_name} && bundle exec rails #{args.join(" ")}")
      end

      desc "console", %(Rails console (short-cut alias: "c"))
      def console
        determine_folder_name
        system("cd #{folder_name} && bundle exec rails console")
      end

      desc "generate", %(Rails generator (short-cut alias: "g"))
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
    end
  end
end