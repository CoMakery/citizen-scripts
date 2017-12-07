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
    pushable
    rubocop
    brakeman
    best
    eslint
  end

  def rspec
    run_script :test
  end

  def pushable
    return unless ENV['CI'] || ENV['CODE_PUSH_IN_PROGRESS']
    step "Checking for code that should not be pushed" do
      local_gems = File.readlines('Gemfile').select do |line|
        line.match(/^\s*gem .+ path: '/)
      end
      if !local_gems.empty?
        message = "\nPlease remove local gem(s) before pushing:\n\n#{local_gems.join("\n")}"
        abort colorize :error, message
      end
    end
  end

  def best
    Gem::Specification::find_by_name 'rails_best_practices' # only run this step if gem is installed
    step "Rails Best Practices" do
      shell! "bundle exec rails_best_practices ."
    end
  rescue Gem::MissingSpecError
  end

  def brakeman
    step "Brakeman" do
      shell! "bundle exec brakeman --exit-on-warn --quiet > /dev/null"
    end
  end

  def eslint
    if File.exist?(app_root.join('package.json'))
      step "eslint" do
        if ENV['CI']
          shell! "yarn lint:ci"
        else
          shell! "yarn lint"
        end
      end
    end
  end

  def rubocop
    run_script :cop
  end
end
