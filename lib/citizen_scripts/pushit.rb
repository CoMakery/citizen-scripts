class CitizenScripts::Pushit < CitizenScripts::Base
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
      system('git push origin HEAD')
    end
  end

  def check_clean
    # fails on CI on linux : (
    shell! "if [[ $(git status --porcelain) ]]; then echo 'Please stash or commit changes first\n' && exit 1; fi"
  end
end
