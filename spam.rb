require 'hipchat'
require 'github_api'
require 'pry'

class Spam
  def initialize(options = {})
    @debug = options[:debug]
    @debug = false if @debug.nil?

    @pretty = options[:pretty]
    @pretty = true if @pretty.nil?

    @color = options[:color]
    @color = "random" if @color.nil?

    @name = options[:name]
    @name = "GitCheck" if @name.nil?

    @contributers = [
      Hashie::Mash.new(missed: 0, name: "Tom",    github: "tomprats",     hipchat: "TomPrats"),
      Hashie::Mash.new(missed: 0, name: "Jason",  github: "jasontruluck", hipchat: "JasonTruluck"),
      Hashie::Mash.new(missed: 0, name: "Chris",  github: "cpreisinger",  hipchat: "ChrisPreisinger"),
      Hashie::Mash.new(missed: 0, name: "Carson", github: "carsonwright", hipchat: "CarsonWright"),
      Hashie::Mash.new(missed: 0, name: "Sam",    github: "sam199006",    hipchat: "SamBoyd")
    ]

    git_token = File.open('github.token', &:readline).strip
    hip_token = File.open('hipchat.token', &:readline).strip
    @github = Github.new(oauth_token: git_token)
    @hipchat = HipChat::Client.new(hip_token)
  end

  def time?
    hour = Time.now.hour
    day = Time.now.wday

    hour >= 11 && hour <= 19 && day != 0 && day != 6
  end

  def execute!
    repos = @github.repos.list(org: "woofound")

    pulls = []
    repos.each do |repo|
      pulls << @github.pull_requests.list(user: "woofound", repo: repo.name)
    end

    pulls = pulls.collect { |p| p unless p.body.empty? }.flatten.compact
    pulls.each do |pull|
      check_pull(pull)
    end

    spam_laziest
  end

  private
  # Return users who haven't checked this pull request
  def check_thumbs(comments, pull)
    lazy = []
    @contributers.each do |contributer|
      unless thumbs?(contributer, comments, pull)
        lazy.push("@#{contributer.hipchat}")
        contributer.missed += 1
      end
    end

    lazy
  end

  # Return if contributer has thumbsed it up
  # Creator defaults to true
  def thumbs?(contributer, comments, pull)
    return true if contributer.github == pull.user.login
    return false if comments.empty?
    comments = comments.collect { |c| c if contributer.github == c.user.login }.compact
    comments.collect { |c| c.body.include? ":+1:" }.any?
  end

  # Return if someone has commented since last commit
  # Excludes creator
  def activity?(comments, commits)
    return false if comments.empty?
    last_commit = commits.collect { |c| c.commit.author.date }.max
    last_comment = comments.collect { |c| c.updated_at }.max
    last_comment > last_commit
  end

  # Send a hipchat to contributer with pull_request
  def message(reciever, pull)
    message = "#{reciever}: #{pull.html_url}"
    send_hipchat(message)
  end

  def send_hipchat(message)
    puts "Spamming #{message}"
    unless @debug
      @hipchat['Development'].send(@name, message, :color => @color, :notify => true)
    end
  end

  def output_results(lazy, pull)
    if @pretty
      message = "#{pull.html_url} needs #{lazy.join(' ')}"
      send_hipchat(message)
    else
      lazy.each do |bum|
        message(bum, pull)
      end
    end
  end

  def spam_laziest
    laziest = @contributers.max_by(&:missed)
    message = "@#{laziest.hipchat} you are the laziest of them all"
    send_hipchat(message)
  end

  # Checks pull for necessary comments
  def check_pull(pull)
    comments = get_comments(pull) + get_issue_comments(pull)
    commits = get_commits(pull)

    message("@all", pull) unless activity?(comments, commits) || @pretty

    lazy = check_thumbs(comments, pull)

    unless lazy.empty?
      output_results(lazy, pull)
    end
  end

  # Github pull request relations
  def get_comments(pull)
    @github.pull_requests.comments.list(
      user: "woofound",
      repo: pull.head.repo.name,
      rMaequest_id: pull.number
    ).flatten.compact
  end

  def get_issue_comments(pull)
    @github.issues.comments.list(
        user: "woofound",
        repo: pull.head.repo.name,
        issue_id: pull.number
      ).flatten.compact
  end

  def get_commits(pull)
    @github.pull_requests.commits(
      user: "woofound",
      repo: pull.head.repo.name,
      number: pull.number
    ).flatten.compact
  end
end
