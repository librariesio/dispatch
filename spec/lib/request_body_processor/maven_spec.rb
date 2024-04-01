# frozen_string_literal: true

describe RequestBodyProcessor::Maven do
  describe '.process_names' do
    it 'processes names' do
      expect(described_class.process_names(['cat dog', 'rat dog', 'cat dog', 'test wow whoa',
                                            'test wow cool'])).to contain_exactly(
                                              'catdog', 'ratdog', 'testwow'
                                            )
    end
  end
end
