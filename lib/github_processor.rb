# frozen_string_literal: true

class GithubProcessor
  def initialize(event_sender)
    @event_sender = event_sender
  end

  def process(json_body)
    event = GithubMessageFactory.build(json_body)

    send_event(
      name: event.name,
      params: event.params
    )
  end

  private

  def send_event(name:, params: {})
    puts "Sending '#{name}' event"

    @event_sender.send_event(
      headers: { 'X-GitHub-Event' => name },
      params:
    )
  end
end
