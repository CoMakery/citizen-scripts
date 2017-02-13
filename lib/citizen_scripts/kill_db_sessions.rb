class CitizenScripts::KillDbSessions < CitizenScripts::Base
  def self.description
    "Kills active Postgres sessions"
  end

  def run
    print "Loading Rails... "
    require app_root.join("./config/environment")

    puts "done"

    print "Killing DB sessions... "
    ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT pg_terminate_backend(pg_stat_activity.pid)
      FROM pg_stat_activity
      WHERE datname = current_database()
      AND pid <> pg_backend_pid()
    SQL

    puts "done"
  end
end
