module CitizenCodeScripts; end

require 'citizencode_scripts/base'

Dir.glob('citizencode_scripts/**/*.rb').each { |path| require path }
