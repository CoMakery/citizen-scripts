class Diff < CitizenScripts::Base
  def self.name
    "diff"
  end

  DAY = 86400

  def run
    yesterday = (Time.now - DAY).strftime("%Y-%m-%d")

    last_sha = `git log --after "#{yesterday} 00:00" --before "#{yesterday} 23:59" --format="format:%H"`
      .strip
      .split("\n")
      .last

    start_sha = `git log "#{last_sha}^" --format="format:%H"`
      .strip
      .split("\n")
      .first

    repo = `git remote -v | grep github | awk '{ print $2 }' | head -n 1`.strip
    repo.gsub!(/\.git/, "")
    repo.gsub!(/git@github.com:/, "")

    github_repo = repo.split("/")[-2..-1].join("/")

    system("open https://github.com/#{github_repo}/compare/#{start_sha}...master")
  end
end
