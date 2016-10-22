require 'pathname'
require 'fileutils'

class CitizenCodeScripts::Base
  include CitizenCodeScripts::Colorize
  include FileUtils

  attr_reader :argv

  def initialize(*argv)
    @argv = argv
  end

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
    msg = <<-HELP
Help has not been implemented for "#{name}". Please implement a help method like so:

class #{self} < CitizenCodeScripts::Base
  def self.help
    <<-EOF
    My awesome help message here.

    This will be so useful for people.
    EOF
  end
end
HELP

    puts msg
  end

  def self.description
    ""
  end

  def self.run(*args)
    new(*args).run
  end

  # path to your application root.
  APP_ROOT = Pathname.new Dir.pwd

  def system!(*args)
    puts colorize(light_cyan: args.join(" "))
    system(*args) || abort(colorize(:light_red, "\n== Command #{args} failed =="))
  end

  def step(name)
    puts colorize(:light_yellow, "\n== #{name} ==")
    yield
  end
end
