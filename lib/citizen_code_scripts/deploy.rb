require 'pathname'
require 'fileutils'
require 'yaml'

include FileUtils

module CitizenCodeScripts
  class Deploy < Base
    def self.description
      "Deploys to production or staging"
    end

    def self.help
      <<~TEXT
        USAGE: deploy <staging|prod> <SHA> <source>
        where "source" is either "circle-ci" or blank
      TEXT
    end

    def run
      _command, env, sha, source = ARGV

      chdir app_root do
        config = YAML.load_file("citizen.yml")
        app = config["heroku_app_names"][env]
        raise "app not found in citizen.yml for environment #{env}" if app.nil?

        fail "Env must be 'staging' or 'prod'" unless env == "staging" || env == "prod"

        if sha.nil? || sha.empty?
          fail %|SHA must be provided; try something like "heroku releases -r staging" to see SHAs that are on staging|
        end

        if source == "circle-ci"
          step "Fetching unshallow from git for Circle CI" do
            system! %{bash -c '[[ ! -s "$(git rev-parse --git-dir)/shallow" ]] || git fetch --unshallow'}
          end
        end

        step "Deploying #{sha} to #{app}" do
          system! "git push git@heroku.com:#{app}.git #{sha}:refs/heads/master"
        end

        step "Running migrations" do
          system! "heroku run rake db:migrate -a #{app}"
        end
      end

    end
  end
end