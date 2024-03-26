# frozen_string_literal: true

module RequestBodyProcessor
  class Maven
    def self.process_names(names)
      names.map { |name| name.split[0..1].join }.uniq
    end
  end
end
