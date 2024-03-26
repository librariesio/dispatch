# frozen_string_literal: true

describe GithubProcessor do
  describe '#process' do
    subject(:github_processor) { described_class.new(event_sender) }
    let(:event_sender) { instance_double(EventSender) }

    let(:name) { 'repository' }
    let(:params) { { 'repository' => { 'full_name' => repo_name } } }

    let(:json_body) { JSON.dump(body) }
    let(:repo_name) { 'repo_name' }

    let(:event_type) { 'RepositoryEvent' }

    let(:body) do
      { 'type' => event_type, 'repo' => { 'name' => repo_name } }
    end

    before do
      allow(event_sender).to receive(:send_event).with(headers: { 'X-GitHub-Event' => name }, params: params)
    end

    it 'goes though the happy path' do
      github_processor.process(json_body)

      expect(event_sender).to have_received(:send_event).with(headers: { 'X-GitHub-Event' => name }, params: params)
    end

    context 'with unknown event' do
      let(:event_type) { 'whatever' }

      it 'does not send an event' do
        github_processor.process(json_body)

        expect(event_sender).not_to have_received(:send_event)
      end
    end
  end
end
