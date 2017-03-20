require 'em-eventsource'
require 'json'

class EventSender
  def initialize
    @connection = EventMachine::HttpRequest.new(ENV["EVENT_HOOK_URL"])
  end

  def send_event(name, params = {})
    @connection.post({
      body: JSON.dump(params),
      head: {
        "Content-Type" => "application/json",
        "X-GitHub-Event" => name
      }
    })
  end
end

EM.run do
  source = EM::EventSource.new(ENV["FIREHOSE_URL"])
  sender = EventSender.new

  source.error do |error|
    puts "error #{error}"
  end

  source.on "event" do |message|
    data = JSON.parse(message)

    case data['type']
    when 'RepositoryEvent'
      p 'RepositoryEvent'
      sender.send_event(
        'repository', {
          "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'WatchEvent'
      p 'star'
      sender.send_event('watch', {
        "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'PublicEvent'
      p 'public'
      sender.send_event(
        'public', {
          "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'ReleaseEvent'
      p 'new release'
      sender.send_event(
        'release', {
          "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'ForkEvent'
      p 'new fork'
      # Sidekiq::Client.push('queue' => 'low', 'class' => 'CreateRepositoryWorker', 'args' => ['GitHub', data['repo']['name'], nil])
    when 'IssuesEvent'
      p "Issue #{data['payload']['action']} #{data['repo']['name']}"
      sender.send_event(
        'issues', {
          "action" => data['payload']['action'],
          "issue" => { "number" => data['payload']['issue']['number'] },
          "repository" => { 'id' => data['repo']['id'], "full_name" => data['repo']['name'] },
          'sender' => { 'id' => data['actor']['id'] }
      })
    when 'PullRequestEvent'
      p "Pull Request #{data['payload']['action']} #{data['repo']['name']}"
      sender.send_event(
        'pull_request', {
          "action" => data['payload']['action'],
          "pull_request" => { "number" => data['payload']['pull_request']['number'] },
          "repository" => { 'id' => data['repo']['id'], "full_name" => data['repo']['name'] },
          'sender' => { 'id' => data['actor']['id'] }
      })
    when 'IssueCommentEvent'
      p 'new issue comment'
      sender.send_event(
        'issue_comment', {
          "repository" => { "full_name" => data['repo']['name'] },
          "issue" => { "number" => data['payload']['issue']['number'] }
        }
      )
    when 'CreateEvent'
      p 'new create'
      sender.send_event('create', {
        'ref_type' => data['payload']['ref_type'],
        "repository" => { "full_name" => data['repo']['name'] }
      })
    end
  end

  source.start
end
