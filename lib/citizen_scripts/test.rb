class CitizenScripts::Test < CitizenScripts::Base
  def self.description
    "Runs your RSpec suite"
  end

  def run
    begin
      load(File.expand_path("./spring", __FILE__))
    rescue LoadError
    end

    require 'bundler/setup'

    step "Running RSpec" do
      command = ['bundle', 'exec', 'rspec', *argv]
      shell!(command.join(" "))
    end
  end
end
