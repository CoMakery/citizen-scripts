class CitizenCodeScripts::Pushit < CitizenCodeScripts::Base
  def run
    CitizenCodeScripts::Update.run
    CitizenCodeScripts::Test.run

    step "Pushing" do
      system('git push')
    end
  end
end
