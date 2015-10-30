require 'em-eventsource'
require 'sidekiq'

EM.run do
  source = EM::EventSource.new("http://github-firehose.herokuapp.com/events")

  source.error do |error|
    puts "error #{error}"
  end

  source.on "event" do |message|
    data = JSON.parse(message)
    case data['type']
    when 'WatchEvent'
      Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubStarWorker', 'args' => [data['repo']['name'], nil])
    when 'PublicEvent'
      Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubCreateWorker', 'args' => [data['repo']['name'], nil])
    when 'ReleaseEvent'
      puts 'new release'
    when 'CreateEvent'
      thing = data['payload']['ref_type']
      if thing == 'tag'
        puts 'new tag'
      elsif thing == 'repository'
        Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubCreateWorker', 'args' => [data['repo']['name'], nil])
      end
    end
  end

  source.start
end

# WatchEvent => star
# PublicEvent => new repo
# ReleaseEvent => new release
# CreateEvent => new (repo/branch/tag)

# PushEvent
# CommitCommentEvent
# CreateEvent
# DeleteEvent
# ForkEvent
# GollumEvent
# IssueCommentEvent
# IssuesEvent
# MemberEvent
# PublicEvent
# PullRequestEvent
# PullRequestReviewCommentEvent
# ReleaseEvent
# WatchEvent
