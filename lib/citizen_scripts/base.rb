require 'pathname'
require 'fileutils'
require 'yaml'

class CitizenScripts::Base
  include CitizenScripts::Colorize
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

  def self.inherited(klass)
    CitizenScripts::Base.script_classes << klass
  end

  def self.script_classes
    @script_classes ||= []
  end

  def self.scripts
    @scripts ||= load_scripts_deferred
  end

  def self.load_scripts_deferred
    script_classes.reduce(Hash.new) do |result, klass|
      result[klass.name] = klass
      result
    end
  end

  def self.script_names
    scripts.keys
  end

  def self.help
    msg = <<-HELP
Help has not been implemented for "#{name}". Please implement a help method like so:

class #{self} < CitizenScripts::Base
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
  def app_root
    Pathname.new(Dir.pwd)
  end

  def system!(*args)
    puts colorize(:command, args.join(" "))
    system(*args) || abort(colorize(:error, "\n== Command #{args} failed =="))
  end

  def step(name)
    puts colorize(:info, "\n== #{name} ==")
    yield
  end

  def app_names
    YAML.load_file('citizen.yml')['heroku_app_names']
  end

  def staging_app_name
    app_names['staging']
  end
end
