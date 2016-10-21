class CitizenCodeScripts::Pushit < CitizenCodeScripts::Base
  def run
    begin
      load(File.expand_path("./spring", __FILE__))
    rescue LoadError
    end

    require 'bundler/setup'

    # require 'rspec/core'
    # RSpec::Core::Runner.invoke
    system('ruby', Gem.bin_path('rspec-core', 'rspec'))
  end
end
