module CitizenCodeScripts; end

require 'citizen_code_scripts/base'

Dir.glob('citizen_code_scripts/**/*.rb').each { |path| require path }
