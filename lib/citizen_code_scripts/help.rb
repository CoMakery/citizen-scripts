class CitizenCodeScripts::Help < CitizenCodeScripts::Base
  def run
    puts "Usage: citizen [scriptname]"
    puts
    puts "Specify a specific script to run, options are: "
    puts

    CitizenCodeScripts::Base.scripts.each do |name, script|
      print "  #{name}"
      print " - #{script.description}" unless script.description.empty?
      puts
    end
  end
end
