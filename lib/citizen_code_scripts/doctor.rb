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

      if system "#{command} > /dev/null 2>&1"
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

  def initialize
    @checks = []
    @problems = []
  end

  def run
    preamble
    run_checks
    report
  end

  def check(**options)
    check = Check.new(options)
    check.run!
    @problems += check.problems
  end

  private

  def preamble
    puts "~~~~Checking the health of your development environment~~~~"
    puts "======> https://www.youtube.com/watch?v=Ow4K7xQENS8 <======"
    puts "☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻"
    puts
  end

  def run_checks
    default_checks
  end

  def default_checks
    check_postgres_launchctl
    check_postgres_running
    check_postgres_role
    check_db_migrated
    check_direnv_installed
    check_phantomjs_installed
    check_gemfile_dependencies
    check_envrc_file_exists
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

  def report
    exit @problems.size
  end
end
