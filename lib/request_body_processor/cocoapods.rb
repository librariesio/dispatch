# frozen_string_literal: true

module RequestBodyProcessor
  class Cocoapods
    def self.process_names(names)
      names.map { |name| name.split(' ')[1] }.uniq
    end
  end
end
