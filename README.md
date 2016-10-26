# citizen_code_scripts

Handy scripts for any client project.

## Installation

Add to your project's Gemfile:

```
gem 'citizen_code_scripts', git: 'git@github.com:citizencode/citizen_code_scripts.git'
```

## Getting help

You can run `citizen help` at any time for a list of commands.

Running `citizen help [command name]` will print specific help for that
command.

## Extending/adding commands to your project

Any files in `.citizen/scripts/**/*.rb` will be automatically required
by the `citizen` command on a per-project basis. Any overrides/extensions
can be added in that directory.

## Example of adding a project-specific command

If you have a custom command you'd like to add, just put it in
`.citizen/scripts/custom_command.rb`

Each command needs to subclass `CitizenCodeScripts::Base` and implement
a `run` method.

As an example, here's how you might override the `citizen test` command to
add ESLint as a step:

```
class CustomTest < CitizenCodeScripts::Test
  # override the default 'test' command by naming it
  # the same
  def self.name
    "test"
  end

  def run
    # Other scripts can be reused by calling .run
    CitizenCodeScripts::Rspec.run

    # Adding a custom step to run eslint after RSpec runs
    step "Running eslint" do
      system! "bin/eslint"
    end
  end
end
```

## Extending doctor

Create a file called `.citizen/scripts/doctor.rb`, and as an example:

```ruby
class Doctor < CitizenCodeScripts::Doctor
  def run_checks
    # Use built-in default checks, if still desired
    run_default_checks

    # Add a custom check
    check_aws_configured
  end

  private

  def check_aws_configured
    check(
      name: "AWS env configured",
      command: "cat .envrc | grep AWS_ACCESS_KEY_ID",
      remedy: "cp .envrc .env # and edit"
    )
  end
end
```

If you want to cherry pick some of the default checks, you'll need
to call each of their methods manually. For a list of default checks,
run `citizen doctor list`. Then, create a `.citizen/scripts/doctor.rb` 
file that looks something like this:

```ruby
class Doctor < CitizenCodeScripts::Doctor
  def run_checks
    # Only run these two defaults
    check_envrc_file_exists
    check_phantomjs_installed

    # Add any custom checks here...
  end
end
```

## Copyright

Copyright (c) 2016 Citizen Code. See LICENSE.txt for further details.
