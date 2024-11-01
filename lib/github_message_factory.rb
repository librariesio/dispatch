# frozen_string_literal: true

require 'json'

class GithubMessageFactory
  # GitHub events from the Firehose have a type. Based on that type, create
  # a standard message from the parsed GH event.
  #
  # @return [GithubMessage]
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def self.build(json_body)
    data = JSON.parse(json_body)

    case data['type']
    when 'RepositoryEvent', 'ForkEvent'
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
    else # rubocop:disable Style/EmptyElse
      # There are likely many more event types than what we are looking for.
      # That is not a failure condition.

      nil
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
end
