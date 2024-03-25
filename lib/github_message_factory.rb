# frozen_string_literal: true

require 'json'

class GithubMessageFactory
  def self.build(json_body)
    data = JSON.parse(json_body)

    case data['type']
    when 'RepositoryEvent'
      GithubMessage.new(
        name: 'repository',
        params: { 'repository' => { 'full_name' => data['repo']['name'] } }
      )
    when 'WatchEvent'
      GithubMessage.new(
        name: 'watch',
        params: { 'repository' => { 'full_name' => data['repo']['name'] } }
      )
    when 'PublicEvent'
      GithubMessage.new(
        name: 'public',
        params: { 'repository' => { 'full_name' => data['repo']['name'] } }
      )
    when 'ReleaseEvent'
      GithubMessage.new(
        name: 'release',
        params: { 'repository' => { 'full_name' => data['repo']['name'] } }
      )
    when 'ForkEvent'
      GithubMessage.new(
        name: 'repository',
        params: { 'repository' => { 'full_name' => data['repo']['name'] } }
      )
    when 'IssuesEvent'
      GithubMessage.new(
        name: 'issues',
        params: {
          'action' => data['payload']['action'],
          'issue' => { 'number' => data['payload']['issue']['number'] },
          'repository' => { 'id' => data['repo']['id'], 'full_name' => data['repo']['name'] },
          'sender' => { 'id' => data['actor']['id'] }
        }
      )
    when 'PullRequestEvent'
      GithubMessage.new(
        name: 'pull_request',
        params: {
          'action' => data['payload']['action'],
          'pull_request' => { 'number' => data['payload']['pull_request']['number'] },
          'repository' => { 'id' => data['repo']['id'], 'full_name' => data['repo']['name'] },
          'sender' => { 'id' => data['actor']['id'] }
        }
      )
    when 'IssueCommentEvent'
      GithubMessage.new(
        name: 'issue_comment',
        params: {
          'repository' => { 'full_name' => data['repo']['name'] },
          'issue' => { 'number' => data['payload']['issue']['number'] }
        }
      )
    when 'CreateEvent'
      GithubMessage.new(
        name: 'create',
        params: {
          'ref_type' => data['payload']['ref_type'],
          'repository' => { 'full_name' => data['repo']['name'] }
        }
      )
    end
  end
end
