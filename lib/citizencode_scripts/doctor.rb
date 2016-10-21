class Doctor
  def self.run(*args)
    new(*args).run
  end

  def initialize
    @problems = []
  end

  def run
    puts "~~~~Checking the health of your development environment~~~~"
    puts "======> https://www.youtube.com/watch?v=Ow4K7xQENS8 <======"
    puts "☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻ ☺ ☻"
    puts

    check \
      name: "Postgres launchctl script is linked",
      command: "ls -1 ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist",
      remedy: "ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents"

    check \
      name: "Postgres is running",
      command: "psql -l",
      remedy: "launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"

    check \
      name: "postgres role exists",
      command: "psql -U postgres -l",
      remedy: "createuser --superuser postgres"

    check \
      name: "Gemfile dependencies are up to date",
      command: "bundle check",
      remedy: "bundle"

    check \
      name: "DB is migrated",
      command: "source .envrc && rails runner 'ActiveRecord::Migration.check_pending!'",
      remedy: "rake db:migrate"

    check \
      name: "Direnv installed",
      command: "which direnv",
      remedy: "brew install direnv"

    check \
      name: "PhantomJS installed",
      command: "which phantomjs",
      remedy: "brew install phantomjs"

    check \
      name: "envrc",
      command: "stat .envrc",
      remedy: "Get your .envrc file from 1password"

    report
  end

  private

  def check(name:, command:, remedy:)
    print "Checking: #{name}... "
    if system "#{command} > /dev/null 2>&1"
      puts 'OK'
    else
      print red 'f'
      puts %| To fix, run "#{remedy}"|
      @problems << name
    end
  end

  def report
    exit @problems.size
  end

  def red(s)
    colorize s, 31
  end

  def colorize(s, code)
    "\e[#{code}m#{s}\e[0m"
  end
end
