# citizen_code_scripts

## Getting help

You can run `citizen help` at any time for a list of commands.

Running `citizen help [command name]` will print specific help for that
command.

## Extending/adding commands to your project

Any files in `.citizen/scripts/**/*.rb` will be automatically required
by the `citizen` command on a per-project basis. Any overrides/extensions
can be added in that directory.

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
