class HerokuDoctor < CitizenCodeScripts::Doctor
  def self.description
    <<~TEXT
      Runs checks against your Heroku servers
    TEXT
  end

  def self.help
    <<~TEXT
      citizen heroku-doctor #{colorize(:light_blue, "environment")} = #{colorize(:yellow, "staging")}
    TEXT
  end

  def run_checks
    check_heroku_env_vars_set
  end

  private

  def check_heroku_env_vars_set
    env = argv[0] || "staging"
    heroku_app_name = app_names[env.to_s]
    puts "Checking for environment '#{env}' which is the heroku app named '#{heroku_app_name}'"
    puts
    check(
      name: "Heroku has ENV var for automatic migrations during deploy",
      command: "heroku config:get DEPLOY_TASKS -a #{heroku_app_name} | grep 'db:migrate'",
      remedy: "heroku config:set DEPLOY_TASKS=db:migrate -a #{heroku_app_name}"
    )
    check(
      name: "Heroku has ENV var for RAILS set to the #{env}",
      command: "heroku config:get RAILS_ENV -a #{heroku_app_name} | grep 'production'", # this should change to the env specified
      remedy: "heroku config:set DEPLOY_TASKS=db:migrate -a #{heroku_app_name}"
    )
    check(
      name: "Heroku has necessary ruby buildpack on #{env}",
      command: "heroku buildpacks -a #{heroku_app_name} | grep 'https://github.com/heroku/heroku-buildpack-ruby'",
      remedy: "heroku buildpacks:add https://github.com/heroku/heroku-buildpack-ruby -a #{heroku_app_name}"
    )
    check(
      name: "Heroku has necessary rake-deploy-tasks buildpack on #{env}",
      command: "heroku buildpacks -a #{heroku_app_name} | grep 'https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks'",
      remedy: "heroku buildpacks:add https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks -a #{heroku_app_name}"
    )
  end
end