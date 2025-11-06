# frozen_string_literal: true

require_relative "anthropic_client"
require_relative "../utils/state_manager"
require_relative "../utils/github_helper"
require_relative "../utils/prompt_templates"

module AI
  # Business/Domain expert review agent.
  class BusinessAI
    def initialize(client: AnthropicClient.new, state_manager: Utils::StateManager.new, github: Utils::GithubHelper.new)
      @client = client
      @state_manager = state_manager
      @github = github
    end

    def review(issue_number:)
      issue = @github.fetch_issue(issue_number)
      prompt = Utils::PromptTemplates.business_prompt(issue: issue, state: @state_manager.market_state, strategy: @state_manager.business_strategy)
      response = @client.create_message(system: prompt[:system], context: prompt[:context])
      comment = response.dig(:content, 0, :text)
      @github.create_issue_comment(issue_number: issue_number, body: comment)
    end
  end
end
