# frozen_string_literal: true

require "json"

module Utils
  # Provides prompt templates for each AI role.
  module PromptTemplates
    module_function

    def customer_prompt(state:)
      {
        system: <<~PROMPT,
          役割: タスク管理アプリを利用するWebアプリケーションユーザー
          フェーズ: #{state[:phase]}
          ユーザー数: #{state[:user_count]}
          既存機能: ユーザー登録、タスクCRUD
          制約: Webアプリの体験や機能改善・不具合報告・パフォーマンス改善など、Webアプリ開発に関連する要望に限定する。インフラ構築や外部サービス全般などWebアプリ以外の領域は提案しない。
        PROMPT
        context: <<~CONTEXT
          市場状態: #{state[:market_conditions].to_json}
          これまでのIssueを踏まえてリアルな顧客要望をJSON形式で1件生成してください。
          バックエンドやWeb UIの基本機能に焦点を当て、フロントエンドはシンプルな体験を維持しつつ改善案を検討してください。
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
          対象範囲: Webアプリケーションとしての価値提供に絞り、Web UIおよびRailsバックエンド機能の改善にフォーカスする。
        PROMPT
        context: <<~CONTEXT
          Issue: #{issue[:title]}
          本文: #{issue[:body]}
          市場状態: #{state.to_json}
          ビジネス戦略: #{strategy.to_json}
          Webアプリ開発の観点でビジネス価値と優先度を評価し、不要に広い提案にならないよう注意しながらフィードバックを提供してください。
        CONTEXT
      }
    end

    def pdm_prompt(issue:, roadmap:, metrics:)
      {
        system: <<~PROMPT,
          役割: 経験豊富なプロダクトマネージャー
          目的: RailsベースのWebアプリケーションとしての成長を管理する。
        PROMPT
        context: <<~CONTEXT
          Issue: #{issue[:title]}
          本文: #{issue[:body]}
          ロードマップ: #{roadmap.to_json}
          開発メトリクス: #{metrics.to_json}
          Webアプリのユーザー体験とバックエンド要件のバランスを取りながら、指定テンプレートに沿ってレビューを行ってください。
        CONTEXT
      }
    end

    def design_prompt(pr:)
      diff_reference = pr[:diff_url] || pr[:html_url]
      {
        system: "役割: Webアプリケーションのシステムアーキテクト",
        context: <<~CONTEXT
          Pull Request: #{pr[:title]}
          説明: #{pr[:body]}
          変更点: #{diff_reference}
          RailsバックエンドとシンプルなWeb UIの設計品質に焦点を当て、指定のレビュー形式でフィードバックを出力してください。
        CONTEXT
      }
    end

    def code_review_prompt(pr:)
      {
        system: "役割: 15年以上経験を持つWebアプリケーションのシニアエンジニア",
        context: <<~CONTEXT
          Pull Request: #{pr[:title]}
          説明: #{pr[:body]}
          diff: #{pr[:diff_url]}
          Railsバックエンドと最小限のフロントエンド実装に対するレビューとして、指定フォーマットでフィードバックを提供してください。
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
          Railsを用いたWebアプリケーションとしての仕様に限定して内容を更新し、構造を保ったままMarkdown全文を出力してください。
        CONTEXT
      }
    end
  end
end
