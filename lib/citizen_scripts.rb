require 'rubygems'

module CitizenScripts; end

require_relative './citizen_scripts/colorize'
require_relative './citizen_scripts/base'

search_path = File.dirname(__FILE__) + '/citizen_scripts/**/*.rb'
Dir.glob(search_path).each { |path| require path }
