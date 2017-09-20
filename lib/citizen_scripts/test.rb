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
    check_clean
    shell! "bin/rubocop"
    shell! "yarn lint"
    check_clean
    shell! "bundle exec brakeman --exit-on-warn --quiet > /dev/null"
    shell! "bundle exec rails_best_practices ."
    CitizenScripts::Rspec.run
  end

  def check_clean
    shell! "if [[ $(git status --porcelain) ]]; then echo 'Please stash or commit changes first\n' && exit 1; fi"
  end
end
