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
    env = argv[0] || "staging"
    heroku_app_name = app_names[env.to_s]
    puts "Checking for environment '#{env}' which is the heroku app named '#{heroku_app_name}'"
    puts

    # this one should always be first - it will NEVER pass for the citizen-rails project which is OKAY!
    check_citizen_yml_configured

    check_app_exists(heroku_app_name)
    check_heroku_env_vars_set(env, heroku_app_name)
  end

  def check_app_exists(heroku_app_name)
    check(
      name: "App #{heroku_app_name} exists",
      command: "cat .git/config | grep git@heroku.com:#{heroku_app_name}.git",
      remedy: %|"heroku apps:create #{heroku_app_name}" and/or "git remote add staging git@heroku.com:#{heroku_app_name}.git"|
    )
  end

  private

  def check_citizen_yml_configured
    check(
      name: "The citizen.yml file has been configured properly",
      command: "! grep 'citizen-rails-staging' citizen.yml",
      remedy: "Configure your citizen.yml file to have the correct app names set for all your Heroku environments"
    )
  end

  def check_heroku_env_vars_set(env, heroku_app_name)
    check(
      name: "Heroku has ENV var for automatic migrations during deploy",
      command: "heroku config:get DEPLOY_TASKS -a #{heroku_app_name} | grep 'db:migrate'",
      remedy: "heroku config:set DEPLOY_TASKS=db:migrate -a #{heroku_app_name}"
    )
    check(
      name: "Heroku has ENV var for RAILS set to the #{env}",
      command: "heroku config:get RAILS_ENV -a #{heroku_app_name} | grep '#{env}'", # this should change to the env specified
      remedy: "heroku config:set RAILS_ENV=#{env} -a #{heroku_app_name}"
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
