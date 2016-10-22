class CitizenCodeScripts::Rspec < CitizenCodeScripts::Base
  def run
    begin
      load(File.expand_path("./spring", __FILE__))
    rescue LoadError
    end

    require 'bundler/setup'

    # require 'rspec/core'
    # RSpec::Core::Runner.invoke
    system(Gem.bin_path('rspec-core', 'rspec'), *argv)
  end
end
