class CitizenScripts::Test < CitizenScripts::Base
  def self.description
    "Runs all test suites for CI/pushit"
  end

  def run
    step "Running test suite" do
      rspec
    end
  end

  private

  def rspec
    CitizenScripts::Rspec.run
  end
end
