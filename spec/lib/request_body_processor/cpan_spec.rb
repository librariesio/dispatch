# frozen_string_literal: true

describe RequestBodyProcessor::Cpan do
  describe '.process_names' do
    it 'processes names' do
      expect(described_class.process_names(
               'hits' => {
                 'hits' => [
                   { 'fields' => { 'distribution' => 'dog' } },
                   { 'fields' => { 'distribution' => 'dog' } },
                   { 'fields' => { 'distribution' => 'wow' } }
                 ]
               }
             )).to contain_exactly(
               'dog', 'wow'
             )
    end
  end
end
