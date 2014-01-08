require 'hipchat'
require 'github_api'
require 'pry'

class Spam
  def initialize
    @contributers = [
      Hashie::Mash.new(:name => "Tom",    :github => "tomprats",     :hipchat => "TomPrats"),
      Hashie::Mash.new(:name => "Jason",  :github => "jasontruluck", :hipchat => "JasonTruluck"),
      Hashie::Mash.new(:name => "Chris",  :github => "cpreisinger",  :hipchat => "ChrisPreisinger"),
      Hashie::Mash.new(:name => "Carson", :github => "carsonwright", :hipchat => "CarsonWright"),
      Hashie::Mash.new(:name => "Sam",    :github => "sam199006",    :hipchat => "iSamBoyd")
    ]
    git_token = File.open('github.token', &:readline).strip
    hip_token = File.open('hipchat.token', &:readline).strip
    @github = Github.new(oauth_token: git_token)
    @hipchat = HipChat::Client.new(hip_token)
  end

  def time?
    hour = Time.now.hour
    day = Time.now.wday

    hour > 11 && hour < 19 && day != 0 && day != 6
  end

  def execute!
    repos = @github.repos.list(org: "woofound")

    pulls = []
    repos.each do |repo|
      pulls << @github.pull_requests.list(user: "woofound", repo: repo.name)
    end

    pulls = pulls.collect { |p| p unless p.body.empty? }.flatten.compact
    pulls.each do |pull|
      comments = @github.pull_requests.comments.list(
        user: "woofound",
        repo: pull.head.repo.name,
        rMaequest_id: pull.number
      ).flatten.compact

      comments += @github.issues.comments.list(
        user: "woofound",
        repo: pull.head.repo.name,
        issue_id: pull.number
      ).flatten.compact

      commits = @github.pull_requests.commits(
        user: "woofound",
        repo: pull.head.repo.name,
        number: pull.number
      ).flatten.compact


      message_all(pull) unless activity?(comments, commits)
      @contributers.each do |contributer|
        message(contributer, pull) unless thumbs?(contributer, comments, pull)
      end
    end
  end

  private
  # Send a hipchat to the main room
  def message_all(pull)
    message = "@all: #{pull.html_url}"
    puts "Spamming #{message}"
    @hipchat['Development'].send('GitCheck', message, :color => 'random', :notify => true)
  end

  # If contributer has thumbsed it up
  # Creator defaults to true
  def thumbs?(contributer, comments, pull)
    return true if contributer.github == pull.user.login
    return false if comments.empty?
    comments = comments.collect { |c| c if contributer.github == c.user.login }.compact
    comments.collect { |c| c.body.include? ":+1:" }.any?
  end

  # If someone has commented since last commit
  # Excludes creator
  def activity?(comments, commits)
    return false if comments.empty?
    last_commit = commits.collect { |c| c.commit.author.date }.max
    last_comment = comments.collect { |c| c.updated_at }.max
    last_comment > last_commit
  end

  # Send a hipchat to contributer with pull_request
  def message(contributer, pull)
    message = "@#{contributer.hipchat}: #{pull.html_url}"
    puts "Spamming #{message}"
    @hipchat['Development'].send('GitCheck', message, :color => 'random', :notify => true)
  end
end
