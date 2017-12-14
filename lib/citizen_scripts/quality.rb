require 'rubygems'

class CitizenScripts::Quality < CitizenScripts::Base
  def self.description
    "Runs code quality checks"
  end

  def run
    pushable
    rubocop
    brakeman
    best
    eslint
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
      shell! "bundle exec brakeman --exit-on-warn --quiet"
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
