describe GithubProcessor do
  describe '#process' do
    subject(:github_processor) { described_class.new(event_sender) }
    let(:event_sender) { instance_double(EventSender) }

    let(:name) { 'repository' }
    let(:params) { { "repository" => { "full_name" => repo_name } } }

    let(:json_body) { JSON.dump(body) }
    let(:repo_name) { 'repo_name' }

    let(:body) do
      { "type" => "RepositoryEvent", "repo" => { "name" => repo_name } }
    end

    before do
      allow(event_sender).to receive(:send_event).with(headers: { 'X-GitHub-Event' => name }, params: params)
    end

    it 'goes though the happy path' do
      github_processor.process(json_body)

      expect(event_sender).to have_received(:send_event).with(headers: { 'X-GitHub-Event' => name }, params: params)
    end
  end
end
