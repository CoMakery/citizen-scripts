class CitizenCodeScripts::Help < CitizenCodeScripts::Base
  def run
    puts "Usage: citizen [scriptname]"
    print "Specify a specific script to run, options are: "
    puts CitizenCodeScripts::Base.script_names.join(', ')
    exit
  end
end
