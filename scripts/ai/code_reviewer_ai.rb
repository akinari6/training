# frozen_string_literal: true

require_relative "anthropic_client"
require_relative "../utils/github_helper"
require_relative "../utils/prompt_templates"

module AI
  # Code review automation agent.
  class CodeReviewerAI
    def initialize(client: AnthropicClient.new, github: Utils::GithubHelper.new)
      @client = client
      @github = github
    end

    def review(pull_request_number:)
      pr = @github.fetch_pull_request(pull_request_number)
      prompt = Utils::PromptTemplates.code_review_prompt(pr: pr)
      response = @client.create_message(system: prompt[:system], context: prompt[:context])
      comment = response.dig(:content, 0, :text)
      @github.create_pr_comment(pull_request_number: pull_request_number, body: comment)
    end
  end
end
