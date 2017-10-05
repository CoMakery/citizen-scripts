class CitizenScripts::Checks < CitizenScripts::Base
  def self.description
    "Runs all tests and other code checks"
  end

  def run
    if ENV['CI']
      rspec
      quality_checks
    else
      quality_checks
      rspec
    end
  end

  def quality_checks
    rubocop
    brakeman
    best
    eslint
  end

  def rspec
    CitizenScripts::Test.run
  end

  def best
    step "Rails Best Practices" do
      shell! "bundle exec rails_best_practices ."
    end
  end

  def brakeman
    step "Brakeman" do
      shell! "bundle exec brakeman --exit-on-warn --quiet > /dev/null"
    end
  end

  def eslint
    step "JS Lint" do
      shell! "yarn lint"
    end
  end

  def rubocop
    step "Rubocop" do
      shell! "bin/rubocop"
    end
  end
end
