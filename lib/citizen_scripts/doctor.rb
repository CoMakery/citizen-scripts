class CitizenScripts::Doctor < CitizenScripts::Base
  class Check
    include CitizenScripts::Colorize

    attr_reader :name, :command, :remedy, :problems

    def initialize(name:, command:, remedy:)
      @name = name
      @command = command
      @remedy = remedy
      @problems = []
    end

    def run!
      print "Checking: #{name}... "

      success = if command.respond_to?(:call)
        command.call
      else
        system "#{command} > /dev/null 2>&1"
      end

      if success
        puts 'OK'
      else
        print colorize(:error, 'F')
        fix = remedy.respond_to?(:join) ? remedy.join(" ") : remedy
        puts "\n  To fix: #{fix}\n\n"

        problems << name
      end
    end
  end

  def self.description
    "Checks the health of your development environment"
  end

  def initialize(*args)
    super
    @checks = []
  end

  def run
    case argv.first
    when "list"
      list_default_checks
    else
      run_doctor
    end
  end

  def self.help
    "doctor - helps you diagnose any setup issues with this application\n"
  end

  def self.help_subcommands
    {
      "citizen doctor" => "runs health checks and gives a report",
      "citizen doctor list" => "prints a list of default checks you can use when overriding doctor checks in your app"
    }
  end

  def run_doctor
    run_checks
    report
  end

  def list_default_checks
    puts "These default checks are available for use in your overrides:"
    puts

    default_checks.each do |name|
      puts "  - #{colorize(:light_blue, name)}"
    end

    puts
  end

  def check(**options)
    check = Check.new(options)
    @checks << check

    check.run!
  end

  private

  def run_checks
    run_default_checks
  end

  def run_default_checks
    default_checks.each do |check|
      send(check)
    end
  end

  def default_checks
    %i[
      check_envrc_file_exists
      check_direnv_installed
      check_gemfile_dependencies
      check_postgres_launchctl
      check_postgres_running
      check_postgres_role
      check_db_exists
      check_db_migrated
      check_phantomjs_installed
    ]
  end

  def check_postgres_launchctl
    check \
      name: "postgres launchctl script is linked",
      command: "ls -1 ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist",
      remedy: command("ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents")
  end

  def check_postgres_running
    check \
      name: "postgres is running",
      command: "psql -l",
      remedy: command("launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist")
  end

  def check_postgres_role
    check \
      name: "postgres role exists",
      command: "psql -U postgres -l",
      remedy: command("createuser --superuser postgres")
  end

  def check_gemfile_dependencies
    check \
      name: "Gemfile dependencies are up to date",
      command: "bundle check",
      remedy: command("bundle")
  end

  def check_db_exists
    check \
      name: "Development database exists",
      command: "source .envrc && rails runner -e development 'ActiveRecord::Base.connection'",
      remedy: command("rake db:setup")

    check \
      name: "Test database exists",
      command: "source .envrc && rails runner -e test 'ActiveRecord::Base.connection'",
      remedy: command("rake db:setup")
  end

  def check_db_migrated
    check \
      name: "DB is migrated",
      command: "source .envrc && rails runner 'ActiveRecord::Migration.check_pending!'",
      remedy: command("rake db:migrate")
  end

  def check_direnv_installed
    check \
      name: "direnv installed",
      command: "which direnv",
      remedy: command("brew install direnv")
  end

  def check_phantomjs_installed
    check \
      name: "PhantomJS installed",
      command: "which phantomjs",
      remedy: command("brew install phantomjs")
  end

  def check_envrc_file_exists
    check \
      name: ".envrc file exists",
      command: "stat .envrc",
      remedy: command("cp .envrc.sample .envrc")
  end

  def check_env_file_exists
    check \
      name: ".env file exists (for 'heroku local')",
      command: "stat .env",
      remedy: command("ln -s .envrc .env")
  end

  def problems
    @checks.map(&:problems).flatten
  end

  def report
    exit problems.size
  end

  def command(s)
    "run #{colorize :command, s}"
  end
end
