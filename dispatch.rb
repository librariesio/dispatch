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
      p 'star'
      Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubStarWorker', 'args' => [data['repo']['name'], nil])
    when 'PublicEvent'
      p 'pubic'
      Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubCreateWorker', 'args' => [data['repo']['name'], nil])
    when 'ReleaseEvent'
      p 'new release'
      Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubUpdateWorker', 'args' => [data['repo']['name'], nil])
    when 'ForkEvent'
      p 'new fork'
      Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubUpdateWorker', 'args' => [data['repo']['name'], nil])
    when 'CreateEvent'
      thing = data['payload']['ref_type']
      if thing == 'tag'
        p 'new tag'
        Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubTagWorker', 'args' => [data['repo']['name'], nil])
      elsif thing == 'repository'
        p 'new repo'
        Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubCreateWorker', 'args' => [data['repo']['name'], nil])
      end
    end
  end

  source.start
end

# PushEvent
# CommitCommentEvent
# DeleteEvent
# GollumEvent
# IssueCommentEvent
# IssuesEvent
# MemberEvent
# PullRequestEvent
# PullRequestReviewCommentEvent
