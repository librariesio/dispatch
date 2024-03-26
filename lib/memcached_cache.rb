# frozen_string_literal: true

class MemcachedCache
  MEMCACHED_OPTIONS = {
    server: (ENV['MEMCACHIER_SERVERS'] || 'localhost:11211').split(','),
    username: ENV.fetch('MEMCACHIER_USERNAME', nil),
    password: ENV.fetch('MEMCACHIER_PASSWORD', nil),
    failover: true,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2
  }.freeze

  def self.client
    Dalli::Client.new(
      MEMCACHED_OPTIONS[:server],
      MEMCACHED_OPTIONS.except(:server)
    )
  end
end
