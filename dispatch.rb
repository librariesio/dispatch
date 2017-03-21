require 'em-eventsource'
require 'json'

class EventSender
  def initialize(url)
    @connection = EventMachine::HttpRequest.new(url)
  end

  def send_event(headers: {}, params: {})
    @connection.post({
      body: JSON.dump(params),
      head: { "Content-Type" => "application/json" }.merge(headers)
    })
  end
end

class GithubProcessor
  def initialize(url)
    @sender = EventSender.new(url)
  end

  def process(message)
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

  private

  def send_event(name, params = {})
    puts "Sending '#{name}' event"

    @sender.send_event(
      headers: { "X-GitHub-Event" => name },
      params: params
    )
  end
end

class Watcher
  JSON_SERVICES = [
    ['http://npm-update-stream.libraries.io/', 'NPM'],
    ['https://rubygems.org/api/v1/activity/just_updated.json', 'Rubygems'],
    ['https://rubygems.org/api/v1/activity/latest.json', 'Rubygems'],
    ['https://atom.io/api/packages?page=1&sort=created_at&direction=desc', 'Atom'],
    ['https://atom.io/api/packages?page=1&sort=updated_at&direction=desc', 'Atom'],
    ['http://package.elm-lang.org/new-packages', 'Elm'],
    ['https://crates.io/summary', 'Cargo'],
    ['http://api.metacpan.org/v0/release/_search?q=status:latest&fields=distribution&sort=date:desc&size=100', 'CPAN'],
    ['https://hex.pm/api/packages?sort=inserted_at', 'Hex'],
    ['https://hex.pm/api/packages?sort=updated_at', 'Hex']
  ]

  def initialize(url)
    @sender = EventSender.new(url)
  end

  def call
    JSON_SERVICES.each do |service|
      process(*service, :json)
    end
  end

  private

  def process(url, platform, type)
    with_names(url, platform, type) do |names|
      names.each do |name|
        puts "WATCHER: #{platform}/#{name}"

        @sender.send_event(
          params: { platform: platform, name: name }
        )
      end
    end
  end

  def with_names(url, platform, type, &block)
    if type == :json
      with_json_names(url, platform, &block)
    end
  end

  def with_json_names(url, platform, &block)
    request = EventMachine::HttpRequest.new(url)
      .get({
      head: { "User-Agent" => "Libraries.io Watcher" }
    })

    request.callback do
      json = JSON.parse(request.response)

      if platform == 'Elm'
        names = json
      elsif platform == 'NPM'
        names = json
      elsif platform == 'Cargo'
        updated_names = json['just_updated'].map{|c| c['name']}
        new_names = json['new_crates'].map{|c| c['name']}
        names = (updated_names + new_names).uniq
      elsif platform == 'CPAN'
        names = json['hits']['hits'].map{|project| project['fields']['distribution'] }.uniq
      else
        names = json.map{|g| g['name']}.uniq
      end

      update_names = []

      yield ((names - update_names))

      #dc.set(url, names)
    end
  end
end

EM.run do
  # Watcher
  watcher = Watcher.new(ENV["WATCHER_HOOK_URL"])
  watcher.call
  #EventMachine.add_periodic_timer(30) { watcher.call }

  # Github event processing
  github = GithubProcessor.new(ENV["GITHUB_HOOK_URL"])
  source = EM::EventSource.new(ENV["FIREHOSE_URL"])
  source.on "event", &github.method(:process)
  source.error {|e| puts "error #{e}" }
  source.start
end
