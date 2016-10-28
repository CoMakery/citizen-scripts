class HerokuDoctor < CitizenCodeScripts::Doctor
  def self.help
    <<-TEXT
      citizen heroku-doctor
    TEXT
  end

  def self.description
    <<-TEXT
      citizen heroku-doctor

      Runs checks against your Heroku staging server to ensure it is configured properly
    TEXT
  end

  def run_checks
    check_heroku_env_vars_set
  end

  private

  def check_heroku_env_vars_set
    check(
      name: "Heroku has ENV var for automatic migrations during deploy",
      command: "env heroku config:get DEPLOY_TASKS -a#{staging_app_name} | grep 'db:migrate'",
      remedy: "heroku config:set DEPLOY_TASKS=db:migrate -a #{staging_app_name}"
    )
  end
end