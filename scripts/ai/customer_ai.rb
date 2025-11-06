# frozen_string_literal: true

require 'json'
require_relative 'anthropic_client'
require_relative '../utils/state_manager'
require_relative '../utils/github_helper'
require_relative '../utils/prompt_templates'

module AI
  # Customer agent generates issues that simulate real user requests.
  class CustomerAI
    def initialize(client: AnthropicClient.new, state_manager: Utils::StateManager.new, github: Utils::GithubHelper.new)
      @client = client
      @state_manager = state_manager
      @github = github
    end

    def run
      state = @state_manager.market_state
      prompt = Utils::PromptTemplates.customer_prompt(state: state)
      response = @client.create_message(system: prompt[:system], context: prompt[:context])
      payload = parse_response(response)
      @github.create_issue(payload)
    end

    private

    def parse_response(response)
      body = response.dig(:content, 0, :text)
      # Remove markdown code block formatting if present
      clean_body = body.gsub(/^```json\n/, '').gsub(/\n```$/, '')
      JSON.parse(clean_body, symbolize_names: true)
    rescue JSON::ParserError => e
      raise "Failed to parse customer AI response: #{e.message}\n#{body}"
    end
  end
end
