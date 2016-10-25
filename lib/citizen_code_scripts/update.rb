class CitizenCodeScripts::Update < CitizenCodeScripts::Base
  def self.help
    <<-EOF
citizen update

This script is a way to update your development environment automatically.
EOF
  end

  def self.description
    "Updates your dev environment automatically"
  end

  def run
    step "Pulling from git" do
      system! "git pull --rebase"
    end

    step "Installing dependencies" do
      system! 'gem install bundler --conservative'
      system('bundle check') || system!('bundle install')
    end

    step "Updating database" do
      system! 'rake db:migrate'
    end

    step "Removing old logs and tempfiles" do
      system! 'rake log:clear tmp:clear'
    end

    step "Attempting to restart Rails" do
      output = `bin/rails restart`

      if $?.exitstatus > 0
        skip_rails_restart_msg
      else
        puts output
      end
    end
  end

  private

  def skip_rails_restart_msg
    puts colorize(
      :light_red,
      "skipping restart, not supported in this version of Rails (needs >= 5)"
    )
  end
end
