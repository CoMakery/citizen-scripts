class CitizenScripts::Deploy < CitizenScripts::Base
  def self.description
    "Deploy to heroku"
  end

  def self.help
    <<-EOF
citizen deploy

Deploys to heroku and runs migrations
EOF
  end

  def run
    argv = ARGV.dup
    argv.shift

    if argv.empty?
      STDERR.puts 'Usage: citizen deploy staging|production|other [git ref] [heroku base app name]'
      exit 1
    end

    heroku_env, git_ref, app_name = argv
    git_ref ||= 'HEAD'
    app_name ||= Dir.pwd.split(File::SEPARATOR).last

    heroku_app = "#{app_name}-#{heroku_env}"
    git_remotes = %W[
      https://git.heroku.com/#{heroku_app}.git
      git@heroku.com:#{heroku_app}.git
    ]

    shell! "heroku maintenance:on --app #{heroku_app}"
    begin
      shell! '[[ ! -s "$(git rev-parse --git-dir)/shallow" ]] || git fetch --unshallow'
      shell! git_remotes.map { |remote| "git push --force #{remote} #{git_ref}:master" }.join(' || ')
      shell! "heroku run --exit-code rake db:migrate --app #{heroku_app}"
    ensure
      shell 7.times.map { "heroku restart --app #{heroku_app}" }.join(' || ')
      shell! "heroku maintenance:off --app #{heroku_app}"
    end
  end
end
