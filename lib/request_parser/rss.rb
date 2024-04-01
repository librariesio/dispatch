# frozen_string_literal: true

require 'simple-rss'

module RequestParser
  class Rss
    def self.parse(response_body)
      SimpleRSS.parse(response_body).entries.map(&:title).compact
    end
  end
end
