# frozen_string_literal: true

require 'dalli'

class ProcessedPackageNamesCache
  def initialize(cache:)
    @cache = cache
  end

  # @yield [String] The list of names not already in the cache
  def cache_names(url:, names:)
    existing_names = @cache.fetch(url) { [] }

    remaining_names = names - existing_names

    yield remaining_names

    @cache.set(url, names)
  end
end
