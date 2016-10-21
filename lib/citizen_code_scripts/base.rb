require 'pathname'
require 'fileutils'

class CitizenCodeScripts::Base
  include FileUtils

  def self.name
    self
      .to_s
      .split('::')
      .last
      .gsub(/[A-Z]/, "-\\0")
      .downcase[1..-1]
  end

  def self.scripts
    @scripts ||= {}
  end

  def self.script_names
    scripts.keys
  end

  def self.inherited(sub_class)
    scripts[sub_class.name] = sub_class
  end

  def self.help
    puts "Help has not been implemented for #{self}"
  end

  def self.run(*args)
    new(*args).new
  end

  # path to your application root.
  APP_ROOT = Pathname.new Dir.pwd

  COLOR_CODES = {
    black: 30,
    blue: 34,
    brown: 33,
    cyan: 36,
    dark_gray: 90,
    green: 32,
    light_blue: 94,
    light_cyan: 96,
    light_gray: 37,
    light_green: 92,
    light_purple: 95,
    light_red: 91,
    light_yellow: 93,
    purple: 35,
    red: 31,
    white: 97,
    yellow: 33,
  }

  def system!(*args)
    puts colorize(light_cyan: args.join(" "))
    system(*args) || abort(colorize(light_red: "\n== Command #{args} failed =="))
  end

  def step(name)
    puts colorize(light_yellow: "\n== #{name} ==")
    yield
  end

  def colorize(colors_and_strings)
    colors_and_strings.map do |color, string|
      "\e[#{COLOR_CODES[color]}m#{string}\e[0m"
    end.join
  end
end
