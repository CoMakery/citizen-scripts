require 'json'
require 'tempfile'

module CitizenCodeScripts
  class Pivotal
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def request(url, method: "GET", body: nil)
      cmd = %Q{curl --silent -X #{method} -H "X-TrackerToken: #{token}"}
      cmd += %Q{ -H "Content-Type: application/json"}

      if body
        cmd += %Q{ -d '#{body}'}
      end

      cmd += %Q{ "#{url}"}

      result = `#{cmd}`

      JSON.parse(result.strip)
    end
  end

  class Begin < Base
    def help
      puts 'Usage:'
      puts '  bin/begin [story id] [branch name]'

      puts 'All branch names will be auto-converted to kebab-case, lowercase'

      puts 'Passing story id/branch name as arguments are optional - if they are missing,'
      puts "you'll be prompted."

      exit
    end

    def run(argv)
      help if argv[0] == 'help' || argv[0] == '-h'

      story_id, branch_name = argv

      if !command?("hub")
        abort <<-EOF
You need to install `hub` before you can use this program.

brew install hub
EOF
      end

      pivotal = Pivotal.new(git_config("user.pivotalApiToken"))
      config_abort_if_blank!("user.pivotalApiToken", pivotal.token)

      project_id = git_config("user.pivotalProjectId")
      config_abort_if_blank!("user.pivotalProjectId", project_id)

      story_id ||= prompt("Please paste the Pivotal story ID here")
      story_id = story_id.gsub(/[^\d]/, '')

      story_url = "https://www.pivotaltracker.com/services/v5"\
        "/projects/#{project_id}/stories/#{story_id}"

      story = pivotal.request(story_url)

      default_branch_name = normalized_branch_name(story['name'])

      branch_name ||= prompt("Please enter a branch name (#{default_branch_name})")

      if branch_name.strip == ""
        branch_name = default_branch_name
      else
        branch_name = normalized_branch_name(branch_name)
      end

      # Start the story
      pivotal.request(story_url, method: "PUT", body: '{ "current_state":"started" }')

      silent "git checkout master",
        "git fetch origin",
        "git reset --hard origin/master"

      puts "==> Checking out #{branch_name}"

      silent "git checkout -b #{branch_name}",
        'git commit --allow-empty -m "Initial commit for story #' + story_id + '"',
        "git push origin #{branch_name}",
        "git branch --set-upstream #{branch_name} origin/#{branch_name}"

      tasks = pivotal.request(
      "https://www.pivotaltracker.com/services/v5"\
        "/projects/#{project_id}/stories/#{story_id}/tasks"
      )

      story_description = story['description']

      if story_description.nil?
        story_description = "_No story description given in Pivotal_"
      end

      description = <<-EOF
#{story['name']}

#{story['url']}

# Description

#{story_description}
EOF

      description.strip!

      unless tasks.empty?
        description += "\n\n## TODO\n\n"

        tasks.each do |task|
          description += "- [ ] #{task['description']}\n"
        end

        description.strip!
      end

      puts "==> Opening pull request on GitHub"

      tempfile = Tempfile.new('begin_pull_request')

      begin
        tempfile.write(description)
        tempfile.close

        labels = ['WIP', story['story_type']].join(',')

        url = `hub pull-request -F #{tempfile.path} -l "#{labels}" -a "" -o`

        # Copy it to your clipboard
        system("echo #{url} | pbcopy")
        puts url
      ensure
        tempfile.unlink
      end
    end

    private

    def silent(*cmds)
      cmds.each { |cmd| system("#{cmd} >/dev/null 2>&1") }
    end

    def command?(name)
      `which #{name}`
      $?.success?
    end

    def git_config(key)
      `git config --local --get #{key}`.strip
    end

    def config_abort_if_blank!(key, value)
      if value.strip == ""
        abort <<-EOF
You need to set the #{key} value in your git config!

git config --local --add #{key} [value]
EOF
      end
    end

    def prompt(msg)
      print "#{msg} > "
      value = STDIN.gets.strip
      puts
      value
    end

    def normalized_branch_name(branch_name)
      branch_name
        .gsub(/[^\w\s-]/, '')
        .gsub(/\s+/, '-')
        .downcase
        .gsub(/-*$/, '') # trailing dashes
    end
  end
end
