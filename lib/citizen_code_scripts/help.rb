class CitizenCodeScripts::Help < CitizenCodeScripts::Base
  def run
    specific_script = argv[0]

    if CitizenCodeScripts::Base.script_names.include?(specific_script)
      script = CitizenCodeScripts::Base.scripts[specific_script]
      puts script.help
    elsif specific_script
      puts colorize(:red, "\"#{specific_script}\" does not exist, cannot display help")
    else
      basic_usage
    end
  end

  private

  def basic_usage
    puts "Usage: citizen #{colorize(:light_blue, '[script name]')}"
    puts
    puts "Specify a specific script to run, options are: "
    puts

    CitizenCodeScripts::Base.scripts.each do |name, script|
      print "  #{colorize(:light_green, name)}"

      unless script.description.empty?
        print " - #{colorize(:light_blue, script.description)}"
      end

      puts
    end
  end
end
