require 'em-eventsource'
require 'sidekiq'

EM.run do
  source = EM::EventSource.new(ENV["FIREHOSE_URL"])

  source.error do |error|
    puts "error #{error}"
  end

  source.on "event" do |message|
    data = JSON.parse(message)
    case data['type']
    when 'RepositoryEvent'
      p 'RepositoryEvent'
      Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubUpdateWorker', 'args' => [data['repo']['name'], nil])
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
      # Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubUpdateWorker', 'args' => [data['repo']['name'], nil])
    when 'IssuesEvent'
      case data['payload']['action']
      when 'opened', 'closed', 'reopened', 'labeled', 'unlabeled', 'edited'
        p "Issue #{data['payload']['action']} #{data['repo']['name']}"
        # Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubIssueWorker', 'args' => [data['repo']['name'], data['payload']['issue']['number'],nil])
      end
    when 'PullRequestEvent'
      case data['payload']['action']
      when 'opened', 'closed', 'reopened', 'labeled', 'unlabeled', 'edited'
        p "Pull Request #{data['payload']['action']} #{data['repo']['name']}"
        # Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubIssueWorker', 'args' => [data['repo']['name'], data['payload']['pull_request']['number'], nil])
      end
    when 'IssueCommentEvent'
      p 'new issue comment'
      # Sidekiq::Client.push('queue' => 'low', 'class' => 'GithubIssueWorker', 'args' => [data['repo']['name'], data['payload']['issue']['number'],nil])
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
