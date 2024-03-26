# frozen_string_literal: true

describe RequestBodyProcessor::Pub do
  describe '.process_names' do
    it 'processes names' do
      expect(described_class.process_names(['cat dog', 'rat dog', 'test wow whoa'])).to contain_exactly('dog', 'whoa')
    end
  end
end
