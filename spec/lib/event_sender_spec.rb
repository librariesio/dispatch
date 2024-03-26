# frozen_string_literal: true

describe EventSender do
  describe '#send_event' do
    subject(:event_sender) { described_class.new(url) }

    let(:params) { { test: 'param' } }
    let(:headers) { { header: 'testheader' } }
    let(:url) { 'http://example.com' }

    context 'with successful request' do
      before do
        stub_request(:post, url)
          .with(body: JSON.dump(params), headers: {
                  'Content-Type' => 'application/json',
                  'User-Agent' => 'Libraries.io Dispatch',
                  'header' => 'testheader'
                })
      end

      it 'sends an event' do
        event_sender.send_event(headers:, params:)

        expect(WebMock).to have_requested(:post, url)
          .with(body: JSON.dump(params), headers: {
                  'Content-Type' => 'application/json',
                  'User-Agent' => 'Libraries.io Dispatch',
                  'header' => 'testheader'
                })
      end
    end

    context 'with failing request' do
      before do
        stub_request(:post, url)
          .with(body: JSON.dump(params), headers: {
                  'Content-Type' => 'application/json',
                  'User-Agent' => 'Libraries.io Dispatch',
                  'header' => 'testheader'
                })
          .to_return(status: [403, 'Forbidden'])
      end

      it 'logs an error' do
        event_sender.send_event(headers:, params:)
      end
    end
  end
end
