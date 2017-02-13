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
    CitizenScripts::Update.run
    CitizenScripts::Test.run

    step "Pushing" do
      system('git push')
    end
  end
end
