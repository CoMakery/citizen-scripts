class CitizenCodeScripts::KillDbSessions < CitizenCodeScripts::Base
  def run
    puts 'APP_ROOT', APP_ROOT
    puts 'Dir.pwd', Dir.pwd
    # require_relative APP_ROOT + '/config/environment'

    # ActiveRecord::Base.connection.execute(<<-SQL)
    #     SELECT pg_terminate_backend(pg_stat_activity.pid)
    #       FROM pg_stat_activity
    #      WHERE datname = current_database()
    #        AND pid <> pg_backend_pid()
    # SQL
  end
end
