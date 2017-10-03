class CitizenScripts::Checks < CitizenScripts::Base
  def self.description
    "Runs all tests and other code checks"
  end

  def run
    CitizenScripts::Test.run

    step "Rubocop" do
      shell! "bin/rubocop"
    end
    step "JS Lint" do
      shell! "yarn lint"
    end
    step "Brakeman" do
      shell! "bundle exec brakeman --exit-on-warn --quiet > /dev/null"
    end
    step "Rails Best Practices" do
      shell! "bundle exec rails_best_practices ."
    end
  end
end
