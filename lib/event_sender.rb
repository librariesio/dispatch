# frozen_string_literal: true

require 'rest-client'

class EventSender
  def initialize(url)
    @url = url
  end

  def send_event(headers: {}, params: {})
    DispatchClient.post(
      @url,
      params: params,
      headers: headers
    )
  rescue StandardError => e
    StructuredLog.capture('EVENT_SENDER_ERROR', { url: @url, message: e.message })
  end
end
