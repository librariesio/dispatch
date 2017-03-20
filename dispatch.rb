require 'em-eventsource'
require 'json'

class EventSender
  def initialize
    @connection = EventMachine::HttpRequest.new(ENV["EVENT_HOOK_URL"])
  end

  def parse(message)
    data = JSON.parse(message)

    case data['type']
    when 'RepositoryEvent'
      send_event(
        'repository', {
          "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'WatchEvent'
      send_event('watch', {
        "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'PublicEvent'
      send_event(
        'public', {
          "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'ReleaseEvent'
      send_event(
        'release', {
          "repository" => { "full_name" => data['repo']['name'] }
      })
    when 'ForkEvent'
      # send_event(
      #   'repository', {
      #     "repository" => { "full_name" => data['repo']['name'] }
      # })
    when 'IssuesEvent'
      send_event(
        'issues', {
          "action" => data['payload']['action'],
          "issue" => { "number" => data['payload']['issue']['number'] },
          "repository" => { 'id' => data['repo']['id'], "full_name" => data['repo']['name'] },
          'sender' => { 'id' => data['actor']['id'] }
      })
    when 'PullRequestEvent'
      send_event(
        'pull_request', {
          "action" => data['payload']['action'],
          "pull_request" => { "number" => data['payload']['pull_request']['number'] },
          "repository" => { 'id' => data['repo']['id'], "full_name" => data['repo']['name'] },
          'sender' => { 'id' => data['actor']['id'] }
      })
    when 'IssueCommentEvent'
      send_event(
        'issue_comment', {
          "repository" => { "full_name" => data['repo']['name'] },
          "issue" => { "number" => data['payload']['issue']['number'] }
        }
      )
    when 'CreateEvent'
      send_event('create', {
        'ref_type' => data['payload']['ref_type'],
        "repository" => { "full_name" => data['repo']['name'] }
      })
    end
  end

  def send_event(name, params = {})
    puts "Sending '#{name}' event"
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
  sender = EventSender.new
  source = EM::EventSource.new(ENV["FIREHOSE_URL"])
  source.on "event", &sender.method(:parse)
  source.error {|e| puts "error #{e}" }
  source.start
end
