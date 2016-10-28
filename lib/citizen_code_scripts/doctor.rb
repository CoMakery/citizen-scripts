class CitizenCodeScripts::Doctor < CitizenCodeScripts::Base
  class Check
    include CitizenCodeScripts::Colorize

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
        print colorize(:red, 'f')
        puts %| To fix, run "#{remedy}"|

        problems << name
      end
    end
  end

  def self.description
    "Call 1-555-DOCTORB. The 'B' is for 'bargain'."
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
    preamble
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

  def preamble
    puts "~~~~Checking the health of your development environment~~~~"
    puts "======> https://www.youtube.com/watch?v=Ow4K7xQENS8 <======"
    puts "☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻"
    puts
  end

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
      check_postgres_launchctl
      check_postgres_running
      check_postgres_role
      check_db_migrated
      check_direnv_installed
      check_phantomjs_installed
      check_gemfile_dependencies
      check_envrc_file_exists
    ]
  end

  def check_postgres_launchctl
    check \
      name: "Postgres launchctl script is linked",
      command: "ls -1 ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist",
      remedy: "ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents"
  end

  def check_postgres_running
    check \
      name: "Postgres is running",
      command: "psql -l",
      remedy: "launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
  end

  def check_postgres_role
    check \
      name: "postgres role exists",
      command: "psql -U postgres -l",
      remedy: "createuser --superuser postgres"
  end

  def check_gemfile_dependencies
    check \
      name: "Gemfile dependencies are up to date",
      command: "bundle check",
      remedy: "bundle"
  end

  def check_db_migrated
    check \
      name: "DB is migrated",
      command: "source .envrc && rails runner 'ActiveRecord::Migration.check_pending!'",
      remedy: "rake db:migrate"
  end

  def check_direnv_installed
    check \
      name: "Direnv installed",
      command: "which direnv",
      remedy: "brew install direnv"
  end

  def check_phantomjs_installed
    check \
      name: "PhantomJS installed",
      command: "which phantomjs",
      remedy: "brew install phantomjs"
  end

  def check_envrc_file_exists
    check \
      name: "envrc",
      command: "stat .envrc",
      remedy: "Get your .envrc file from 1password"
  end

  def problems
    @checks.map(&:problems).flatten
  end

  def report
    exit problems.size
  end
end
