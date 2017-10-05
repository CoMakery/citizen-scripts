class CitizenScripts::Shipit < CitizenScripts::Base
  def self.description
    "Pulls code, runs test, pushes your code"
  end

  def self.help
    <<-EOF
citizen pushit

Pulls the latest code, restarts, runs the tests, and pushes
your new code up.
    EOF
  end

  def run
    run_script :update
    check_clean
    run_script :checks
    check_clean

    step "Pushing" do
      system 'git push origin HEAD'
    end
  end

  def check_clean
    step "Check for clean git status" do
      if `git status --porcelain`.strip.length > 0
        colorize :error, 'Please stash or commit changes first'
        exit 1
      end
    end
  end
end
