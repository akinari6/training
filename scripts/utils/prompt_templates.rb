# frozen_string_literal: true

require "json"

module Utils
  # Provides prompt templates for each AI role.
  module PromptTemplates
    module_function

    def customer_prompt(state:)
      {
        system: <<~PROMPT,
          役割: タスク管理アプリを使用する一般ユーザー
          フェーズ: #{state[:phase]}
          ユーザー数: #{state[:user_count]}
          既存機能: ユーザー登録、タスクCRUD
        PROMPT
        context: <<~CONTEXT
          市場状態: #{state[:market_conditions].to_json}
          これまでのIssueを踏まえてリアルな顧客要望をJSON形式で1件生成してください。
          出力形式:
          {
            "title": "簡潔なタイトル",
            "body": "詳細な説明(背景、要望内容、期待効果)",
            "priority": "high|medium|low",
            "type": "feature|improvement|bug|performance",
            "labels": ["customer-request", "phase-#{state[:phase]}"]
          }
        CONTEXT
      }
    end

    def business_prompt(issue:, state:, strategy:)
      {
        system: <<~PROMPT,
          役割: 5年以上のドメイン経験を持つビジネスステークホルダー
          プロダクトビジョン: #{strategy[:vision]}
          ターゲットユーザー: #{strategy[:target_users].join(", ")}
        PROMPT
        context: <<~CONTEXT
          Issue: #{issue[:title]}
          本文: #{issue[:body]}
          市場状態: #{state.to_json}
          ビジネス戦略: #{strategy.to_json}
          上記を踏まえ、ビジネス観点でのフィードバックを提供してください。
        CONTEXT
      }
    end

    def pdm_prompt(issue:, roadmap:, metrics:)
      {
        system: <<~PROMPT,
          役割: 経験豊富なプロダクトマネージャー
        PROMPT
        context: <<~CONTEXT
          Issue: #{issue[:title]}
          本文: #{issue[:body]}
          ロードマップ: #{roadmap.to_json}
          開発メトリクス: #{metrics.to_json}
          指定のテンプレートに従ってレビューを行ってください。
        CONTEXT
      }
    end

    def design_prompt(pr:)
      diff_reference = pr[:diff_url] || pr[:html_url]
      {
        system: "役割: システムアーキテクト",
        context: <<~CONTEXT
          Pull Request: #{pr[:title]}
          説明: #{pr[:body]}
          変更点: #{diff_reference}
          設計レビュー形式に沿ったフィードバックを出力してください。
        CONTEXT
      }
    end

    def code_review_prompt(pr:)
      {
        system: "役割: 15年以上経験を持つシニアエンジニア",
        context: <<~CONTEXT
          Pull Request: #{pr[:title]}
          説明: #{pr[:body]}
          diff: #{pr[:diff_url]}
          指定フォーマットでコードレビューを提供してください。
        CONTEXT
      }
    end

    def documentation_prompt(pr:, specification:)
      {
        system: "役割: テクニカルライター",
        context: <<~CONTEXT
          既存仕様書:\n#{specification}
          PRタイトル: #{pr[:title]}
          PR本文: #{pr[:body]}
          変更差分: #{pr[:diff_url]}
          仕様書の構造を保ったまま更新したMarkdown全文を出力してください。
        CONTEXT
      }
    end
  end
end
