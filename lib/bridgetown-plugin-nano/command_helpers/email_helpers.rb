# frozen_string_literal: true

module BridgetownPluginNano
  module Commands
    class Nano < Thor
      module EmailHelpers
        def configure_action_mailer
          self.destination_root = File.expand_path(folder_name)

          say_status :nano, %(Setting up ActionMailer in "#{folder_name}")
          directory "email", ".", exclude_pattern: %r!DS_Store$!
          inject_into_file "config/application.rb",
                           "require \"action_mailer/railtie\"\n",
                           after: "require \"action_controller/railtie\"\n"
          append_to_file(
            "config/base_classes.rb",
            "\n" + File.read("#{self.class.source_root}/base_classes/application_mailer.rb")
          )

          say_status :nano, "ActionMailer configuration complete!"
          say_status :nano, "Take a look at #{folder_name}/test_mailer.rb for an example mailer,"
          say_status :nano, "and #{folder_name}/config/initializers/email.rb to set " \
                            "up your SMTP connection."
        end
      end
    end
  end
end
