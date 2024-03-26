# frozen_string_literal: true

module RequestBodyProcessor
  class Hex
    def self.process_names(json)
      json.map { |g| g['name'] }.uniq
    end
  end
end
