# frozen_string_literal: true

describe RequestBodyProcessor::Hackage do
  describe '.process_names' do
    it 'processes names' do
      expect(described_class.process_names([
                                             'dog cat', 'wow test whoa', 'dog woof'
                                           ])).to contain_exactly(
                                             'dog', 'wow'
                                           )
    end
  end
end
