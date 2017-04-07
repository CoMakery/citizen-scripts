class CitizenScripts::Update < CitizenScripts::Base
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
    pull_git
    install_dependencies
    update_db
    remove_old_logs
    restart_servers
  end

  private

  def pull_git
    step "Pulling from git" do
      system! "git pull --rebase"
    end
  end

  def install_dependencies
    step "Installing dependencies" do
      if bundler?
        system! 'command -v bundler > /dev/null || gem install bundler --conservative'
        system! 'bundle install'
      end

      if yarn?
        system! "yarn install"
      end
    end
  end

  def update_db
    if rails?
      step "Updating database" do
        system! 'rake db:migrate db:test:prepare'
      end
    end
  end

  def remove_old_logs
    if rails?
      step "Removing old logs and tempfiles" do
        system! 'rake log:clear tmp:clear'
      end
    end
  end

  def restart_servers
    restart_rails if rails?
  end

  def restart_rails
    step "Attempting to restart Rails" do
      output = `bin/rails restart`

      if $?.exitstatus > 0
        puts colorize(
          :light_red,
          "skipping restart, not supported in this version of Rails (needs >= 5)"
        )
      else
        puts output
      end
    end
  end
end
