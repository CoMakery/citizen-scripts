class CitizenCodeScripts::Pushit < CitizenCodeScripts::Base
  def self.description
    "Pulls code, runs test, pushes your code"
  end

  def run
    CitizenCodeScripts::Update.run
    CitizenCodeScripts::Test.run

    step "Pushing" do
      system('git push')
    end
  end
end
