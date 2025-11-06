# AI 駆動型開発プロセスシミュレーション環境 (Ruby on Rails)

このリポジトリは、ジュニアエンジニアが大規模プロダクトの開発サイクルを学習できるようにするためのシミュレーション環境です。ベースアプリケーションにはRuby on Railsを採用し、GitHub Actionsと外部AI APIを組み合わせて実際の開発プロセスを模倣します。

## 主要コンポーネント

- **Task Management Application**: Rails 7によるフルスタックWebアプリケーション。ユーザー認証とタスク管理機能を提供します。
- **AIエージェント群**: Anthropic Claude APIを利用した自動レビュー&フィードバックボット群。
- **市場環境シミュレータ**: フェーズ進行や市場パラメータを管理するRubyスクリプト。
- **CI/CD**: GitHub Actionsベースのパイプライン。RSpecによるテスト、Rubocopによる静的解析、パフォーマンス計測などを実行します。

## 初期セットアップ

> **Note**: この環境では外部ネットワークへのアクセスが制限されており、Bundlerでのgem取得が失敗する場合があります。その場合はローカル環境で `bundle install` を実行してください。

```bash
# 依存関係のインストール (AIスクリプトも含める場合)
bundle install --with ai

# Railsアプリケーションの初期設定
bin/setup

# データベースのセットアップ
bin/rails db:setup

# 開発サーバ起動
bin/dev
```

`bin/rails`, `bin/rake`, `bin/dev` は `src/bin` のラッパーであり、リポジトリのルートから直接利用できます。

### 必要な環境変数

`.env` またはGitHub Actions secretsに以下を設定します。

- `ANTHROPIC_API_KEY`
- `GITHUB_ACCESS_TOKEN`
- `DATABASE_URL` (本番環境ではPostgreSQLを想定)

## ディレクトリ構成

```
.
├── .github/workflows/      # GitHub Actions 設定
├── scripts/                # AIエージェント/パフォーマンス関連スクリプト
├── src/                    # Railsアプリケーション本体
├── state/                  # 市場・開発メトリクス
├── docs/                   # 設計/仕様ドキュメント
├── tests/                  # 補助的なテストリソース
├── README.md
└── SPECIFICATION.md
```

## テスト

```bash
bundle exec rspec
```

### カバレッジ計測

```bash
COVERAGE=true bundle exec rspec
```

## GitHub Actions Secrets

| Secret | 用途 |
|--------|------|
| `ANTHROPIC_API_KEY` | Claude APIへのアクセスキー |
| `GITHUB_TOKEN` (自動) | ワークフロー内GitHub APIアクセス |
| `GITHUB_ACCESS_TOKEN` | 拡張APIアクセスが必要な場合 |

## 開発フロー

1. 顧客AIがIssueを生成
2. 要件定義/設計レビューを経てRailsアプリに実装
3. PR作成後にコードレビューAIとパフォーマンス評価が実行
4. マージ後に仕様書と市場状態を自動更新

詳細なワークフローは `SPECIFICATION.md` を参照してください。

## 参考ドキュメント

- [Rails Guides](https://guides.rubyonrails.org/)
- [Anthropic Claude API Docs](https://docs.anthropic.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

