class TodayI
  def self.run(*args)
    new(*args).run
  end

  def run
    date_string = Time.now.to_s.split(' ')[0]
    lines = `git log --date=local --oneline --after="#{date_string} 00:00" --before="#{date_string} 23:59"`

    lines.each_line do |line|
      puts line.split(" ", 2)[1]
    end
  end
end
