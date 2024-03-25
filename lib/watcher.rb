# frozen_string_literal: true

class Watcher
  JSON_SERVICES = [
    ['https://fastapi.metacpan.org/v1/release/_search?q=status:latest&fields=distribution&sort=date:desc&size=100', 'CPAN'],
    ['https://hex.pm/api/packages?sort=inserted_at', 'Hex'],
    ['https://hex.pm/api/packages?sort=updated_at', 'Hex']
  ].freeze

  MEMCACHED_OPTIONS = {
    server: (ENV['MEMCACHIER_SERVERS'] || 'localhost:11211').split(','),
    username: ENV['MEMCACHIER_USERNAME'],
    password: ENV['MEMCACHIER_PASSWORD'],
    failover: true,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2
  }.freeze

  RSS_SERVICES = [
    ['https://hackage.haskell.org/packages/recent.rss', 'Hackage'],
    ['https://pub.dartlang.org/feed.atom', 'Pub'],
    ['http://cocoapods.libraries.io/feed.rss', 'CocoaPods'],
    ['https://mvnrepository.com/feeds/rss2.0.xml', 'Maven']
  ].freeze

  def initialize(url)
    @sender = EventSender.new(url)
    @cache = Dalli::Client.new(
      MEMCACHED_OPTIONS[:server],
      MEMCACHED_OPTIONS.reject { |k, _v| k == :server }
    )
  end

  def call
    JSON_SERVICES.each do |service|
      process(*service, :json)
    end

    RSS_SERVICES.each do |service|
      process(*service, :rss)
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

  def with_names(url, platform, type)
    cached_names = @cache.fetch(url) { [] }

    begin
      request = RestClient.get(url, 'User-Agent' => 'Libraries.io Watcher')

      if type == :json
        names = with_json_names(request.body, platform)
      elsif type == :rss
        names = with_rss_names(request.body, platform)
      end

      yield (names - cached_names)

      @cache.set(url, names)
    rescue StandardError => e
      puts "Error: #{url} --> #{e}"
      return []
    end
  end

  def with_json_names(request_body, platform)
    json = JSON.parse(request_body)

    if platform == 'CPAN'
      names = json['hits']['hits'].map { |project| project['fields']['distribution'] }.uniq
    else
      names = json.map { |g| g['name'] }.uniq
    end

    names.uniq
  end

  def with_rss_names(request_body, platform)
    names = SimpleRSS.parse(request_body).entries.map(&:title)
    names.map do |name|
      if platform == 'Pub' && name
        name.split(' ').last
      elsif platform == 'CocoaPods' && name
        name.split(' ')[1]
      elsif platform == 'Maven' && name
        name.split(' ')[0] + name.split(' ')[1]
      elsif name
        name.split(' ').first
      end
    end.uniq
  end
end
