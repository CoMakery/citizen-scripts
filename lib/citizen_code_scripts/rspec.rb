class CitizenCodeScripts::Rspec < CitizenCodeScripts::Base
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
      command = [Gem.bin_path('rspec-core', 'rspec')] + argv
      system!(command.join(" "))
    end
  end
end
