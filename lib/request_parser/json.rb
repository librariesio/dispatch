# frozen_string_literal: true

module RequestParser
  class Json
    def self.parse(response)
      JSON.parse(response)
    end
  end
end
