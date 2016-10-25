class CitizenCodeScripts::TodayI < CitizenCodeScripts::Base
  def self.help
    <<-EOF
citizen today-i

Prints out a list of commit message names that you worked on today.
EOF
  end

  def self.description
    "Prints a list of commit msgs from today"
  end

  def run
    date_string = Time.now.to_s.split(' ')[0]

    lines = %x{
      git log \
        --date=local \
        --oneline \
        --after="#{date_string} 00:00" \
        --before="#{date_string} 23:59"
    }

    lines.each_line do |line|
      puts line.split(" ", 2)[1]
    end
  end
end
