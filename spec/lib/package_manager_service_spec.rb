# frozen_string_literal: true

describe PackageManagerService do
  describe '#process' do
    subject(:package_manager_service) do
      described_class.new(
        url: source_url,
        platform: platform,
        request_parser: request_parser,
        request_body_processor: request_body_processor
      )
    end

    let(:source_url) { 'http://example.com' }
    let(:target_url) { 'http://example.com' }
    let(:platform) { 'platform' }
    let(:request_parser) { RequestParser::Json }
    let(:request_body_processor) { RequestBodyProcessor::Hex }

    let(:sender) { EventSender.new(target_url) }
    let(:cache) { double }
    let(:names_cache) { ProcessedPackageNamesCache.new(cache: cache) }

    let(:name) { 'name' }

    before do
      stub_request(:post, target_url).with(
        body: JSON.dump(platform: platform, name: name)
      )

      allow(cache).to receive(:fetch).with(source_url).and_return([])
      allow(cache).to receive(:set).with(source_url, [name])
    end

    context 'with successful request' do
      before do
        stub_request(:get, source_url).to_return_json(
          body: [{ name: name }]
        )
      end

      it 'happy path processes' do
        package_manager_service.process(
          sender: sender, names_cache: names_cache
        )

        expect(WebMock).to have_requested(:post, target_url).with(
          body: JSON.dump(platform: platform, name: name)
        )
        expect(cache).to have_received(:set).with(source_url, [name])
      end
    end

    context 'with client error' do
      before do
        stub_request(:get, source_url).to_return(
          status: 403
        )
      end

      it 'happy path fails' do
        package_manager_service.process(
          sender: sender, names_cache: names_cache
        )

        expect(WebMock).not_to have_requested(:post, target_url).with(
          body: JSON.dump(platform: platform, name: name)
        )
        expect(cache).not_to have_received(:set).with(source_url, [name])
      end
    end
  end
end
