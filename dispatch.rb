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
  # Watcher

  # Github event processing
  event_sender = EventSender.new(ENV['GITHUB_HOOK_URL'])
  github = GithubProcessor.new(event_sender)
  source = EM::EventSource.new(ENV['FIREHOSE_URL'])
  source.on 'event', &github.method(:process)
  source.error { |e| puts "error #{e}" }
  source.start

  watcher = Watcher.new(ENV['WATCHER_HOOK_URL'])
  EventMachine.add_periodic_timer(120) { watcher.call }
  watcher.call
end
