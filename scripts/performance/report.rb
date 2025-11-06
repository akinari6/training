# frozen_string_literal: true

require "json"
require_relative "evaluate"
require_relative "../utils/state_manager"

module Performance
  # Builds a markdown report summarizing performance evaluation results.
  class Report
    def initialize(state_manager: Utils::StateManager.new, evaluator: Evaluate.new(state_manager: state_manager))
      @state_manager = state_manager
      @evaluator = evaluator
    end

    def generate(metrics)
      evaluation = @evaluator.run(metrics: metrics)
      requirements = @state_manager.market_state
      <<~REPORT
        ## 🚀 パフォーマンス評価レポート

        ### 総合判定: #{evaluation[:passed] ? '✅ PASS' : '❌ FAIL'}

        ### 現在のフェーズ要件
        - Phase: #{requirements[:phase]}
        - 想定ユーザー数: #{requirements[:user_count]}
        - 要求レスポンスタイム: #{requirements.dig(:performance_requirements, :max_response_time_ms)}ms 以下
        - 要求DBクエリ数: #{requirements.dig(:performance_requirements, :max_db_queries_per_request)} 以下
        - 要求テストカバレッジ: #{requirements.dig(:performance_requirements, :required_test_coverage_percent)}%以上

        ---

        ### 📊 測定結果
        - レスポンスタイム(P95): #{metrics[:response_time_p95]}ms
        - 平均DBクエリ数: #{metrics[:avg_db_queries]}
        - テストカバレッジ: #{metrics[:test_coverage]}%

        ### 詳細
        #{format_items(evaluation[:items])}
      REPORT
    end

    private

    def format_items(items)
      return "すべての項目が基準を満たしています。" if items.empty?

      items.map do |item|
        "- #{item[:category]}: #{item[:status]} (actual=#{item[:actual]}, expected=#{item[:expected]}, severity=#{item[:severity]})"
      end.join("\n")
    end
  end
end
