# frozen_string_literal: true

require "json"
require_relative "../utils/state_manager"

module Performance
  # Evaluates performance metrics against current phase requirements.
  class Evaluate
    def initialize(state_manager: Utils::StateManager.new)
      @state_manager = state_manager
    end

    def run(metrics:)
      requirements = @state_manager.market_state[:performance_requirements]
      results = {
        passed: true,
        items: []
      }

      if metrics[:response_time_p95] > requirements[:max_response_time_ms]
        results[:passed] = false
        results[:items] << build_item("response_time", "fail", metrics[:response_time_p95], requirements[:max_response_time_ms], "major")
      end

      if metrics[:avg_db_queries] > requirements[:max_db_queries_per_request]
        results[:passed] = false
        results[:items] << build_item("db_queries", "fail", metrics[:avg_db_queries], requirements[:max_db_queries_per_request], "major")
      end

      if metrics[:test_coverage] < requirements[:required_test_coverage_percent]
        results[:passed] = false
        results[:items] << build_item("test_coverage", "fail", metrics[:test_coverage], requirements[:required_test_coverage_percent], "minor")
      end

      results
    end

    private

    def build_item(category, status, actual, expected, severity)
      {
        category: category,
        status: status,
        actual: actual,
        expected: expected,
        severity: severity
      }
    end
  end
end
