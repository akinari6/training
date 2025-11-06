# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module AI
  # Anthropic Claude API client for Ruby workflows.
  class AnthropicClient
    API_URL = "https://api.anthropic.com/v1/messages"

    def initialize(api_key: ENV.fetch("ANTHROPIC_API_KEY", nil))
      @api_key = api_key
    end

    def available?
      !@api_key.to_s.strip.empty?
    end

    def create_message(system:, context:, max_tokens: 1024, temperature: 0.7, model: "claude-sonnet-4-5-20250929")
      raise "ANTHROPIC_API_KEY is not configured" unless available?

      request_body = {
        model: model,
        max_tokens: max_tokens,
        temperature: temperature,
        system: system,
        messages: [
          {
            role: "user",
            content: context
          }
        ]
      }

      uri = URI.parse(API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120

      request = Net::HTTP::Post.new(uri.request_uri)
      request["x-api-key"] = @api_key
      request["anthropic-version"] = "2023-06-01"
      request["content-type"] = "application/json"
      request.body = JSON.dump(request_body)

      response = http.request(request)
      raise "Anthropic API request failed: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
