# frozen_string_literal: true

class Watcher
  PACKAGE_MANAGER_SERVICES = {
    # cpan: PackageManagerService.new(
    #   url: 'https://fastapi.metacpan.org/v1/release/_search?q=status:latest&fields=distribution&sort=date:desc&size=100',
    #   platform: 'CPAN',
    #   request_parser: RequestParser::Json,
    #   request_body_processor: RequestBodyProcessor::Cpan
    # ),
    # hex_inserted_at: PackageManagerService.new(
    #   url: 'https://hex.pm/api/packages?sort=inserted_at',
    #   platform: 'Hex',
    #   request_parser: RequestParser::Json,
    #   request_body_processor: RequestBodyProcessor::Hex
    # ),
    # hex_updated_at: PackageManagerService.new(
    #   url: 'https://hex.pm/api/packages?sort=updated_at',
    #   platform: 'Hex',
    #   request_parser: RequestParser::Json,
    #   request_body_processor: RequestBodyProcessor::Hex
    # ),
    # hackage: PackageManagerService.new(
    #   url: 'https://hackage.haskell.org/packages/recent.rss',
    #   platform: 'Hackage',
    #   request_parser: RequestParser::Rss,
    #   request_body_processor: RequestBodyProcessor::Hackage
    # ),
    # pub: PackageManagerService.new(
    #   url: 'https://pub.dartlang.org/feed.atom',
    #   platform: 'Pub',
    #   request_parser: RequestParser::Rss,
    #   request_body_processor: RequestBodyProcessor::Pub
    # ),
    # Service returning 403 forbidden as of 2024-03-26
    # mvnrepository: PackageManagerService.new(
    #  url: 'https://mvnrepository.com/feeds/rss2.0.xml',
    #  platform: 'Maven',
    #  request_parser: RequestParser::Rss,
    #  request_body_processor: RequestBodyProcessor::Maven
    # )
  }.freeze

  def initialize(event_sender:, names_cache:)
    @event_sender = event_sender
    @names_cache = names_cache
  end

  def call
    PACKAGE_MANAGER_SERVICES.each_value do |service|
      service.process(
        sender: @event_sender,
        names_cache: @names_cache
      )
    end
  end
end
