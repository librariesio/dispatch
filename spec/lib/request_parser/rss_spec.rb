# frozen_string_literal: true

describe RequestParser::Rss do
  describe '.parse' do
    let(:rss_feed) do
      <<~RSS
        <rss>
          <channel>
            <item>
              <title>one</title>
            </item>
            <item>
              <title>two</title>
            </item>
            <item>
            </item>
          </channel>
        </rss>
      RSS
    end

    it 'parses an RSS feed' do
      expect(described_class.parse(rss_feed)).to contain_exactly('one', 'two')
    end
  end
end
