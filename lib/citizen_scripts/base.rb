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

  def run_script(name, *args)
    script = CitizenScripts::Base.scripts[name.to_s]

    if script.nil?
      raise "Could not find script with name #{name.inspect} to run"
    end

    script.run(*args)
  end

  def rails?
    File.exist?("config/application.rb")
  end

  def bundler?
    File.exist?("Gemfile")
  end

  def yarn?
    File.exist?("yarn.lock")
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

  def heroku_app_name(remote)
    app_names[remote.to_s]
  end

  def heroku(command, remote:)
    validate_heroku_remote(remote)
    system! "heroku #{command} -r #{remote}"
  end

  private

  def validate_heroku_remote(remote)
    raise "Missing remote" if remote.nil?
    raise "Unknown remote" unless %w[staging prod].include?(remote.to_s)
  end
end
