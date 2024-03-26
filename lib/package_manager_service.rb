# frozen_string_literal: true

class PackageManagerService
  def initialize(url:, platform:, request_parser:, request_body_processor:)
    @url = url
    @platform = platform
    @request_parser = request_parser
    @request_body_processor = request_body_processor
  end

  def process(sender:, names_cache:)
    with_unprocessed_names(names_cache:) do |name|
      sender.send_event(
        params: { platform: @platform, name: }
      )

      StructuredLog.capture(
        'PACKAGE_MANAGER_SERVICE_UPDATE_PACKAGE',
        { platform: @platform, name: }
      )
    end
  end

  private

  def with_unprocessed_names(names_cache:, &block)
    response = DispatchClient.get(@url)
    parsed_body = @request_parser.parse(response.body)
    names = @request_body_processor.process_names(parsed_body)

    names_cache.cache_names(url: @url, names:) do |unprocessed_names|
      unprocessed_names.each { |name| block.call(name) }
    end
  rescue DispatchClient::ClientError
    StructuredLog.capture(
      'PACKAGE_MANAGER_SERVICE_UPDATE_FAILURE',
      { url: @url }
    )
  end
end
