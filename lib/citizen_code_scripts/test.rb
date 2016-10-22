class CitizenCodeScripts::Test < CitizenCodeScripts::Base
  def self.description
    "Runs all test suites for CI/pushit"
  end

  def run
    rspec
  end

  private

  def rspec
    CitizenCodeScripts::Rspec.run
  end
end
