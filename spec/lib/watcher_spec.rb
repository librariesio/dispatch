# frozen_string_literal: true

describe Watcher do
  describe '#call' do
    subject(:watcher) { described_class.new(event_sender: event_sender, names_cache: names_cache) }
    let(:event_sender) { instance_double(EventSender) }
    let(:names_cache) { NamesCache.new }

    NamesCache = Class.new do
      attr_reader :cache

      def initialize
        @cache = {}
      end

      def cache_names(url:, names:)
        @cache[url] = names

        yield ['package']
      end
    end

    before do
      allow(event_sender).to receive(:send_event).exactly(6).times
    end

    # more specific tests are found for the request parsers and request body processors
    # this test is only about making sure requests and responses for every defined
    # service are working.
    it 'happy path hits every package manager service' do
      VCR.use_cassette('watcher/call') do
        watcher.call
      end

      expect(event_sender).to have_received(:send_event).exactly(1).time.with(params: { platform: 'CPAN',
                                                                                        name: 'package' })
      expect(event_sender).to have_received(:send_event).exactly(2).times.with(params: { platform: 'Hex',
                                                                                         name: 'package' })
      expect(event_sender).to have_received(:send_event).exactly(1).times.with(params: { platform: 'Hackage',
                                                                                         name: 'package' })
      expect(event_sender).to have_received(:send_event).exactly(1).times.with(params: { platform: 'Pub',
                                                                                         name: 'package' })
      expect(event_sender).to have_received(:send_event).exactly(1).times.with(params: { platform: 'CocoaPods',
                                                                                         name: 'package' })

      # Just make sure we loaded something for each feed
      expect(names_cache.cache.length).to eq(6)
      expect(names_cache.cache.values.any?(:empty?)).to eq(false)
    end
  end
end
