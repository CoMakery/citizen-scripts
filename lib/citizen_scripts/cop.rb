class CitizenScripts::Cop < CitizenScripts::Base
  def self.description
    "Runs rubocop"
  end

  def self.help
    <<-EOF
citizen cop

Rubocop checks and fixes
    EOF
  end

  def run
    step "Rubocop" do
      shell! "bin/rubocop"
    end
  end
end
