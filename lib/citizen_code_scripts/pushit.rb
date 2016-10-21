class CitizenCodeScripts::Pushit < CitizenCodeScripts::Base
  def run
    system('git pull --rebase')
    CitizenCodeScripts::Rspec.run && system('git push origin master')
  end
end
