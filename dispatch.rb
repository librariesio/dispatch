# frozen_string_literal: true

require 'zeitwerk'
require 'em-eventsource'
require 'dalli'
require 'simple-rss'

loader = Zeitwerk::Loader.new
loader.push_dir('lib')
loader.setup

$stdout.sync = true

EM.run do
  # Github event processing
  github_event_sender = EventSender.new(ENV.fetch('GITHUB_HOOK_URL', nil))
  github = GithubProcessor.new(github_event_sender)
  source = EM::EventSource.new(ENV.fetch('FIREHOSE_URL', nil))
  source.on 'event', &github.method(:process)
  source.error { |e| puts "error #{e}" }
  source.start

  # Package manager monitoring
  watcher_event_sender = EventSender.new(ENV.fetch('WATCHER_HOOK_URL', nil))
  cache = MemcachedCache.client
  names_cache = ProcessedPackageNamesCache.new(cache: cache)
  watcher = Watcher.new(event_sender: watcher_event_sender, names_cache: names_cache)
  EventMachine.add_periodic_timer(120) { watcher.call }
  watcher.call
end
