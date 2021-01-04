module BridgetownPluginNano
  module Commands
    class Nano < Thor
      module JobsHelpers
        def configure_active_job
          self.destination_root = File.expand_path(folder_name)

          say_status :nano, %(Setting up ActiveJob in "#{folder_name}")
          directory "jobs", ".", exclude_pattern: %r!DS_Store$!
          inject_into_file "config/application.rb",
                           "require \"active_job/railtie\"\n",
                           after: "require \"action_controller/railtie\"\n"

          inject_into_file "config/application.rb",
                           "#  config.active_job.queue_adapter = :sidekiq\n",
                           after: "Rails.logger  = config.logger\n"
          append_to_file(
            "config/base_classes.rb",
            "\n" + File.read("#{self.class.source_root}/base_classes/application_job.rb")
          )

          say_status :nano, "ActiveJob configuration complete!"
          say_status :nano, "Take a look at #{folder_name}/test_job.rb for an example job,"
          say_status :nano, "and #{folder_name}/config/application.rb to set your queue backend (such as Sidekiq)."
        end
      end
    end
  end
end
