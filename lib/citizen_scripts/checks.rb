class CitizenScripts::Checks < CitizenScripts::Base
  def self.description
    "Runs all tests and quality checks"
  end

  def run
    if ENV['CI']
      run_script :test
      run_script :quality
    else
      run_script :quality
      run_script :test
    end
  end
end
