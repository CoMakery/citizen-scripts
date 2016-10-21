module CitizenCodeScripts; end

require_relative './citizen_code_scripts/base'

search_path = File.dirname(__FILE__) + '/citizen_code_scripts/**/*.rb'
Dir.glob(search_path).each { |path| require path }
