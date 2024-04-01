# frozen_string_literal: true

module RequestBodyProcessor
  class Cpan
    def self.process_names(json)
      json['hits']['hits'].map { |project| project['fields']['distribution'] }.uniq
    end
  end
end
