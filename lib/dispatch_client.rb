# frozen_string_literal: true

require 'json'

class DispatchClient
  def self.get(url)
    RestClient.get(url, 'User-Agent' => 'Libraries.io Watcher')
  rescue RestClient::ExceptionWithResponse => e
    StructuredLog.capture('HTTP_CLIENT_ERROR', { url:, status: e.response.code })

    raise e
  end

  def self.post(url, headers: {}, params: {})
    RestClient.post(
      url,
      JSON.dump(params),
      {
        'Content-Type' => 'application/json',
        'User-Agent' => 'Libraries.io Dispatch'
      }.merge(headers)
    )
  rescue RestClient::ExceptionWithResponse => e
    StructuredLog.capture('HTTP_CLIENT_ERROR', { url:, status: e.response.code })

    raise e
  end
end
