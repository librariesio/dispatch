# frozen_string_literal: true

describe RequestParser::Json do
  describe '.parse' do
    let(:json_body) do
      <<~JSON
        { "key": "value" }
      JSON
    end

    it 'parses json' do
      expect(described_class.parse(json_body)).to eq('key' => 'value')
    end
  end
end
