# frozen_string_literal: true

class MemcachedCache
  MEMCACHED_OPTIONS = {
    server: (ENV['MEMCACHIER_SERVERS'] || 'localhost:11211').split(','),
    username: ENV['MEMCACHIER_USERNAME'],
    password: ENV['MEMCACHIER_PASSWORD'],
    failover: true,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2
  }.freeze

  def self.client
    Dalli::Client.new(
      MEMCACHED_OPTIONS[:server],
      MEMCACHED_OPTIONS.reject { |k, _v| k == :server }
    )
  end
end
