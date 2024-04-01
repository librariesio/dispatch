# frozen_string_literal: true

describe RequestBodyProcessor::Hex do
  describe '.process_names' do
    it 'processes names' do
      expect(described_class.process_names([
                                             { 'name' => 'dog' },
                                             { 'name' => 'dog' },
                                             { 'name' => 'wow' }
                                           ])).to contain_exactly(
                                             'dog', 'wow'
                                           )
    end
  end
end
