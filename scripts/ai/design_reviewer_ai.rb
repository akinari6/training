# frozen_string_literal: true

require_relative "anthropic_client"
require_relative "../utils/github_helper"
require_relative "../utils/prompt_templates"

module AI
  # Senior engineer design reviewer agent.
  class DesignReviewerAI
    def initialize(client: AnthropicClient.new, github: Utils::GithubHelper.new)
      @client = client
      @github = github
    end

    def review(pull_request_number:)
      pr = @github.fetch_pull_request(pull_request_number)
      prompt = Utils::PromptTemplates.design_prompt(pr: pr)
      response = @client.create_message(system: prompt[:system], context: prompt[:context])
      comment = response.dig(:content, 0, :text)
      @github.create_pr_comment(pull_request_number: pull_request_number, body: comment)
    end

    def review_issue(issue_number:)
      issue = @github.fetch_issue(issue_number)
      prompt = Utils::PromptTemplates.design_prompt(pr: issue)
      response = @client.create_message(system: prompt[:system], context: prompt[:context])
      comment = response.dig(:content, 0, :text)
      @github.create_issue_comment(issue_number: issue_number, body: comment)
    end
  end
end
