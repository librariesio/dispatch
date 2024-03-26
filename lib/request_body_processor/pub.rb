# frozen_string_literal: true

module RequestBodyProcessor
  class Pub
    def self.process_names(names)
      names.map { |name| name.split.last }.uniq
    end
  end
end
