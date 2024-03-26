# frozen_string_literal: true

module RequestBodyProcessor
  class Hackage
    def self.process_names(names)
      names.map { |name| name.split(' ').first }.uniq
    end
  end
end
