# frozen_string_literal: true

require "json"
require "octokit"

module Utils
  # Minimal helper around Octokit for GitHub API operations.
  class GithubHelper
    def initialize(client: default_client)
      @client = client
      @repository = ENV.fetch("GITHUB_REPOSITORY", nil)
    end

    def create_issue(payload)
      ensure_repository!
      with_safe_api("issue creation") do
        @client.create_issue(@repository, payload[:title], payload[:body], labels: payload_labels(payload))
      end
    end

    def fetch_issue(number)
      ensure_repository!
      @client.issue(@repository, number)
    end

    def create_issue_comment(issue_number:, body:)
      ensure_repository!
      with_safe_api("issue comment") do
        @client.add_comment(@repository, issue_number, body)
      end
    end

    def fetch_pull_request(number)
      ensure_repository!
      @client.pull_request(@repository, number)
    end

    def create_pr_comment(pull_request_number:, body:)
      ensure_repository!
      with_safe_api("pull request comment") do
        @client.add_comment(@repository, pull_request_number, body)
      end
    end

    private

    def default_client
      token = ENV.fetch("GITHUB_ACCESS_TOKEN", ENV.fetch("GITHUB_TOKEN", nil))
      raise "GITHUB_ACCESS_TOKEN or GITHUB_TOKEN must be configured" if token.to_s.empty?

      Octokit::Client.new(access_token: token)
    end

    def payload_labels(payload)
      (Array(payload[:labels]) + [payload[:type], "priority:#{payload[:priority]}"]).compact
    end

    def ensure_repository!
      raise "GITHUB_REPOSITORY must be set" if @repository.to_s.empty?
    end

    def with_safe_api(action_description)
      yield
    rescue Octokit::Forbidden => e
      warn "[GithubHelper] Skipping #{action_description}: #{e.message}"
      nil
    rescue Octokit::Unauthorized => e
      warn "[GithubHelper] GitHub credentials unauthorized for #{action_description}: #{e.message}"
      nil
    end
  end
end
