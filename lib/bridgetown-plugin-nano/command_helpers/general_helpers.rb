# frozen_string_literal: true

module BridgetownPluginNano
  module Commands
    class Nano < Thor
      module GeneralHelpers
        def configure_new_nano_app # rubocop:disable Metrics/MethodLength
          template "bridgetown_root/config.ru", "config.ru"
          copy_file "bridgetown_root/Rakefile", "Rakefile"

          gsub_file "start.js",
                    'sleep 4; yarn serve --port " + port',
                    'sleep 4; bundle exec rake nano:start -- --port=" + port'
          gsub_file "webpack.config.js",
                    %(const path = require("path");\n),
                    %(const path = require("path");\nconst webpack = require("webpack");\n)

          inject_into_file "webpack.config.js", <<-JS, after: "\n  plugins: [\n"
    new webpack.DefinePlugin({
      NANO_API_URL: JSON.stringify(process.env.NANO_API_URL || "/backend")
    }),
          JS

          append_to_file "frontend/javascript/index.js" do
            <<~JS


              (async function () {
                const resp = await fetch(`${NANO_API_URL}/nano`)
                const data = await resp.json()
                document.querySelector("main").innerHTML += `<p><code>${JSON.stringify(data)}</code></p>`
              }())
            JS
          end

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
      end
    end
  end
end
