class CitizenScripts::Promote < CitizenScripts::Base
  def self.description
    "Promote staging to production and run migrations on production"
  end

  def run
    step "Promoting staging to production" do
      heroku "pipelines:promote", remote: :staging
    end

    step "Running migrations on production" do
      heroku "run rails db:migrate", remote: :prod
    end
  end
end
