require_relative './doctor'

class HerokuDoctor < CitizenCodeScripts::Doctor
  def self.description
    "Checks the health of your Heroku config"
  end

  def self.help
    <<~TEXT
      citizen heroku-doctor #{colorize(:light_blue, "environment")} = #{colorize(:yellow, "staging")}
    TEXT
  end

  def run_checks
    @env = argv[0] || "staging"
    @heroku_app_name = app_names[@env.to_s]

    puts "Environment: #{@env}"
    puts "Heroku app:  #{@heroku_app_name}"
    puts

    # this one should always be first - it will NEVER pass for the citizen-rails project which is OKAY!
    check(
      name: "The citizen.yml file has been configured properly",
      command: "! grep 'citizen-rails-staging' citizen.yml",
      remedy: "configure your citizen.yml file to have the correct app names set for all your Heroku environments"
    )

    check(
      name: "app #{@heroku_app_name} exists",
      command: "cat .git/config | grep git@heroku.com:#{@heroku_app_name}.git",
      remedy: [command("heroku apps:create #{@heroku_app_name}"), "and/or", command("git remote add staging git@heroku.com:#{@heroku_app_name}.git")]
    )

    check_env("DEPLOY_TASKS", "db:migrate")
    check_env("RAILS_ENV", "production")
    check_env("DATABASE_URL", "postgres://", "go to https://dashboard.heroku.com/apps/#{@heroku_app_name}/resources and add the Heroku Postgress add-on")

    check_buildpack("https://github.com/heroku/heroku-buildpack-ruby")
    check_buildpack("https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks")
  end

  def check_env(env_var, value, remedy=nil)
    check(
      name: env_var,
      command: "heroku config:get #{env_var} -a #{@heroku_app_name} | grep '#{value}'",
      remedy: remedy || command("heroku config:set #{env_var}=#{value} -a #{@heroku_app_name}")
    )
  end

  def check_buildpack(url)
    check(
      name: url.split("/").last,
      command: "heroku buildpacks -a #{@heroku_app_name} | grep '#{url}'",
      remedy: command("heroku buildpacks:add #{url} -a #{@heroku_app_name}")
    )
  end
end
