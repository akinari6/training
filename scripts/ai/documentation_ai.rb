# frozen_string_literal: true

require_relative "anthropic_client"
require_relative "../utils/state_manager"
require_relative "../utils/github_helper"
require_relative "../utils/prompt_templates"

module AI
  # Documentation agent responsible for updating SPECIFICATION.md
  class DocumentationAI
    def initialize(client: AnthropicClient.new, state_manager: Utils::StateManager.new, github: Utils::GithubHelper.new)
      @client = client
      @state_manager = state_manager
      @github = github
    end

    def update_specification(pull_request_number:)
      pr = @github.fetch_pull_request(pull_request_number)
      prompt = Utils::PromptTemplates.documentation_prompt(pr: pr, specification: File.read("SPECIFICATION.md"))
      response = @client.create_message(system: prompt[:system], context: prompt[:context])
      updated_spec = response.dig(:content, 0, :text)
      File.write("SPECIFICATION.md", updated_spec)
    end
  end
end
