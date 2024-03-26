# frozen_string_literal: true

describe PackageManagerService do
  describe '#process' do
    subject(:package_manager_service) do
      described_class.new(
        url: source_url,
        platform:,
        request_parser:,
        request_body_processor:
      )
    end

    let(:source_url) { 'http://example.com' }
    let(:target_url) { 'http://example.com' }
    let(:platform) { 'platform' }
    let(:request_parser) { RequestParser::Json }
    let(:request_body_processor) { RequestBodyProcessor::Hex }

    let(:sender) { EventSender.new(target_url) }
    let(:cache) { double }
    let(:names_cache) { ProcessedPackageNamesCache.new(cache:) }

    let(:name) { 'name' }

    before do
      stub_request(:get, source_url).to_return_json(
        body: [{ name: }]
      )

      stub_request(:post, target_url).with(
        body: JSON.dump(platform:, name:)
      )

      allow(cache).to receive(:fetch).with(source_url).and_return([])
      allow(cache).to receive(:set).with(source_url, [name])
    end

    it 'happy path processes' do
      package_manager_service.process(
        sender:, names_cache:
      )

      expect(WebMock).to have_requested(:post, target_url).with(
        body: JSON.dump(platform:, name:)
      )
      expect(cache).to have_received(:set).with(source_url, [name])
    end
  end
end
