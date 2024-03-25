# frozen_string_literal: true

require 'rest-client'

class EventSender
  def initialize(url)
    @url = url
  end

  def send_event(headers: {}, params: {})
    RestClient.post(
      @url,
      JSON.dump(params),
      {
        'Content-Type' => 'application/json',
        'User-Agent' => 'Libraries.io Dispatch'
      }.merge(headers)
    )
  rescue StandardError => e
    puts "Error: #{@url} --> #{e}"
  end
end
