# frozen_string_literal: true

describe GithubMessageFactory do
  describe '.build' do
    let(:json_body) { JSON.dump(body) }
    let(:repo_name) { 'repo_name' }
    let(:body) do
      { "type" => "RepositoryEvent", "repo" => { "name" => repo_name } }
    end

    describe 'RepositoryEvent' do
      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('repository')
        expect(result.params).to eq('repository' => { 'full_name' => repo_name })
      end
    end

    describe 'WatchEvent' do
      let(:body) do
        { "type" => "WatchEvent", "repo" => { "name" => repo_name } }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('watch')
        expect(result.params).to eq('repository' => { 'full_name' => repo_name })
      end
    end

    describe 'PublicEvent' do
      let(:body) do
        { "type" => "PublicEvent", "repo" => { "name" => repo_name } }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('public')
        expect(result.params).to eq('repository' => { 'full_name' => repo_name })
      end
    end

    describe 'ReleaseEvent' do
      let(:body) do
        { "type" => "ReleaseEvent", "repo" => { "name" => repo_name } }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('release')
        expect(result.params).to eq('repository' => { 'full_name' => repo_name })
      end
    end

    describe 'ForkEvent' do
      let(:body) do
        { "type" => "ForkEvent", "repo" => { "name" => repo_name } }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('repository')
        expect(result.params).to eq('repository' => { 'full_name' => repo_name })
      end
    end

    describe 'IssuesEvent' do
      let(:body) do
        {
          "type" => "IssuesEvent",
          "payload" => { 'action' => 'action1', 'issue' => { 'number' => 1 } },
          "repo" => { "id" => 2, "name" => repo_name },
          "actor" => { "id" => 3 }
        }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('issues')
        expect(result.params).to eq(
          'action' => 'action1',
          'issue' => { 'number' => 1 },
          'repository' => { 'id' => 2, 'full_name' => repo_name },
          'sender' => { 'id' => 3 }
        )
      end
    end

    describe 'PullRequestEvent' do
      let(:body) do
        {
          "type" => "PullRequestEvent",
          "payload" => { 'action' => 'action1', 'pull_request' => { 'number' => 1 } },
          "repo" => { "id" => 2, "name" => repo_name },
          "actor" => { "id" => 3 }
        }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('pull_request')
        expect(result.params).to eq(
          'action' => 'action1',
          'pull_request' => { 'number' => 1 },
          'repository' => { 'id' => 2, 'full_name' => repo_name },
          'sender' => { 'id' => 3 }
        )
      end
    end

    describe 'IssueCommentEvent' do
      let(:body) do
        {
          "type" => "IssueCommentEvent",
          "payload" => { 'issue' => { 'number' => 1 } },
          "repo" => { "name" => repo_name },
        }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('issue_comment')
        expect(result.params).to eq(
          'issue' => { 'number' => 1 },
          'repository' => { 'full_name' => repo_name }
        )
      end
    end

    describe 'CreateEvent' do
      let(:body) do
        {
          "type" => "CreateEvent",
          "payload" => { "ref_type" => 'ref1' },
          "repo" => { "name" => repo_name },
        }
      end

      it 'constructs correctly' do
        result = described_class.build(json_body)

        expect(result.name).to eq('create')
        expect(result.params).to eq(
          'ref_type' => 'ref1',
          'repository' => { 'full_name' => repo_name }
        )
      end
    end
  end
end
