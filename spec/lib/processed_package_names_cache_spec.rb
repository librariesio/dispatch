# frozen_string_literal: true

describe ProcessedPackageNamesCache do
  subject(:processed_package_names_cache) { described_class.new(cache:) }
  let(:cache) { double }

  let(:existing_name) { 'existing-1' }
  let(:new_name) { 'new-name' }
  let(:url) { 'http://example.com' }

  before do
    allow(cache).to receive(:fetch).with(url).and_return([existing_name])
    allow(cache).to receive(:set).with(url, [existing_name, new_name])
  end

  describe '#cache_names' do
    it 'works with the cache and delivers names' do
      yielded_results = []

      processed_package_names_cache.cache_names(url:, names: [existing_name, new_name]) do |names|
        yielded_results = names
      end

      expect(yielded_results).to contain_exactly(new_name)

      expect(cache).to have_received(:set).with(url, [existing_name, new_name])
    end
  end
end
