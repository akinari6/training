# AI駆動型開発プロセスシミュレーション環境 要件定義書

## 1. プロジェクト概要

### 1.1 目的
ジュニアエンジニアが大規模プロダクト開発における技術的課題とプロセスの複雑さを体験的に学習するため、AI役割を活用した開発サイクルシミュレーション環境を構築する。

### 1.2 目標
- 実際の開発プロセスに近い体験を提供
- 要望整理→要件定義→設計→実装→レビューの一連の流れを実践
- プロダクトの成長に伴う技術的負債と複雑性の増加を体感
- 各ステークホルダーの視点を理解

### 1.3 成果物
- タスク管理アプリケーション(ベースプロダクト)
- GitHub ActionsベースのAI役割システム
- 市場環境シミュレータ
- プロダクト仕様書自動更新システム
- パフォーマンス評価システム

---

## 2. システム構成

### 2.1 アーキテクチャ概要

```
┌─────────────────────────────────────────────────┐
│          GitHub Repository                       │
│  ┌───────────────────────────────────────┐      │
│  │   Task Management Application         │      │
│  │   (Python/Node.js)                    │      │
│  └───────────────────────────────────────┘      │
│                                                  │
│  ┌───────────────────────────────────────┐      │
│  │   GitHub Actions Workflows            │      │
│  │   - Customer Request Generator        │      │
│  │   - Code Review AI                    │      │
│  │   - Design Review AI                  │      │
│  │   - PdM Review AI                     │      │
│  │   - Business/Domain Expert AI         │      │
│  │   - Specification Updater             │      │
│  │   - Performance Checker               │      │
│  └───────────────────────────────────────┘      │
│                                                  │
│  ┌───────────────────────────────────────┐      │
│  │   State Management                    │      │
│  │   - market_state.json                 │      │
│  │   - SPECIFICATION.md                  │      │
│  │   - development_metrics.json          │      │
│  └───────────────────────────────────────┘      │
└─────────────────────────────────────────────────┘
           │
           │ API Calls
           ▼
┌─────────────────────────────────────────────────┐
│   Anthropic Claude API                          │
│   (claude-sonnet-4-5-20250929)                  │
└─────────────────────────────────────────────────┘
```

### 2.2 技術スタック

**ベースアプリケーション:**
- 言語: Python 3.11+ または Node.js 18+
- フレームワーク: FastAPI/Flask または Express
- データベース: SQLite (初期) → PostgreSQL (後期)
- テスト: pytest または Jest

**AI統合:**
- API: Anthropic Claude API
- ライブラリ: anthropic (Python) または @anthropic-ai/sdk (Node.js)

**GitHub連携:**
- GitHub Actions
- PyGithub または @actions/github
- actions/github-script

**パフォーマンス測定:**
- pytest-benchmark または clinic.js
- locust (負荷テスト)

---

## 3. 機能要件

### 3.1 ベースアプリケーション(タスク管理アプリ)

#### 3.1.1 初期実装機能
**必須機能:**
1. ユーザー登録・認証
   - メールアドレスとパスワードでの登録
   - ログイン/ログアウト
   - セッション管理

2. タスクCRUD
   - タスク作成(タイトル、説明、期限、優先度)
   - タスク一覧表示(フィルタ・ソート機能)
   - タスク詳細表示
   - タスク編集
   - タスク削除
   - タスク完了/未完了切り替え

3. データベース設計
   - usersテーブル
   - tasksテーブル
   - 適切なインデックス設定

4. API設計
   - RESTful API
   - 適切なHTTPステータスコード
   - エラーハンドリング

#### 3.1.2 テストカバレッジ要件
- 単体テスト: 主要ロジックのカバレッジ60%以上
- 統合テスト: APIエンドポイントの基本動作確認
- E2Eテスト: 主要ユーザーフロー

#### 3.1.3 パフォーマンス要件(初期)
- レスポンスタイム: 95パーセンタイルで500ms以下
- 同時接続: 50ユーザーまで対応
- データベースクエリ: 1リクエストあたり20クエリ以下

### 3.2 AI役割システム

#### 3.2.1 顧客役AI (Customer Agent)

**トリガー条件:**
- スケジュール: 毎週月曜日 9:00 JST
- 手動トリガー: workflow_dispatch

**入力データ:**
- 現在のプロダクト仕様書(SPECIFICATION.md)
- 市場状態(market_state.json)
- 過去のissue履歴(直近10件)

**処理内容:**
1. 市場状態とフェーズに応じた要望を生成
2. 要望タイプの決定(新機能/改善/バグ/パフォーマンス)
3. Issue作成(title, body, labels)

**出力:**
- GitHub Issue
  - ラベル: `customer-request`, `phase-{N}`
  - テンプレート化された本文
    - 背景・目的
    - 具体的な要望内容
    - 期待される効果
    - 優先度(顧客視点)

**AI プロンプト設計:**
```
役割: タスク管理アプリを使用する一般ユーザー

コンテキスト:
- 現在のプロダクトフェーズ: {phase}
- ユーザー数: {user_count}
- 既存機能: {existing_features}

タスク:
市場状態と既存機能を踏まえ、リアルなユーザー要望を作成してください。

要望タイプ別の出現率:
- 新機能追加: 30%
- 既存機能改善: 40%
- バグ報告: 20%
- パフォーマンス改善: 10%

フェーズ別の複雑度:
- Phase 1-3 (初期): シンプルで基本的な要望
- Phase 4-6 (成長期): より高度で複雑な機能要望
- Phase 7+ (成熟期): 統合、最適化、スケーラビリティに関する要望

出力形式:
{
  "title": "簡潔なタイトル",
  "body": "詳細な説明(背景、要望内容、期待効果を含む)",
  "priority": "high|medium|low",
  "type": "feature|improvement|bug|performance"
}
```

#### 3.2.2 ビジネス職/ドメインマスター役AI (Business Domain Expert)

**トリガー条件:**
- Issue作成時(label: `customer-request`)
- Issueへのコメント追加時(ジュニアエンジニアによる要求整理後)

**入力データ:**
- Issueの内容
- プロダクト仕様書
- 市場状態
- ビジネス戦略(business_strategy.json)

**処理内容:**
1. 顧客要望のビジネス価値評価
2. ドメイン知識に基づく要求の妥当性チェック
3. 不足情報の指摘
4. 代替案の提案(必要に応じて)

**出力:**
- Issueコメント
  - ビジネス観点での評価
  - ドメインロジックとの整合性
  - 質問・指摘事項
  - 承認/修正要求

**AI プロンプト設計:**
```
役割: 
- ビジネス側のステークホルダー(5年以上のドメイン経験)
- タスク管理の業務プロセスに精通

コンテキスト:
- プロダクトのビジョン: {vision}
- 現在の市場ポジション: {market_position}
- ターゲットユーザー: {target_users}

レビュー観点:
1. ビジネス価値の明確性
2. ターゲットユーザーへの影響
3. ドメインロジックとの整合性
4. 実現の緊急性・重要性
5. 競合との差別化要素

評価基準:
- 要求が明確に定義されているか
- ビジネスゴールとの整合性
- 実装の優先順位は適切か
- 必要な情報が揃っているか

出力形式:
承認の場合: "LGTM" + 理由
修正要求の場合: 具体的な指摘と質問
```

#### 3.2.3 PdM役AI (Product Manager)

**トリガー条件:**
- Issueラベル追加時(label: `requirements-defined`)
- 手動トリガー(コメントで @pdm-bot をメンション)

**入力データ:**
- 要件定義書(Issueコメントまたは添付ドキュメント)
- プロダクトロードマップ
- 技術的制約情報
- 開発リソース情報

**処理内容:**
1. 要件の完全性チェック
2. 優先順位の妥当性評価
3. スコープの適切性確認
4. 成功指標(KPI)の設定
5. リスク評価

**出力:**
- Issueコメント
  - 要件評価結果
  - 優先順位の調整提案
  - 成功指標の定義
  - リスクと軽減策
  - 承認/修正要求

**AI プロンプト設計:**
```
役割: 経験豊富なプロダクトマネージャー(8年以上の経験)

コンテキスト:
- プロダクトロードマップ: {roadmap}
- 現在のスプリント状況: {sprint_status}
- 技術的制約: {tech_constraints}
- 開発チームのキャパシティ: {team_capacity}

レビュー観点:
1. ビジネス価値と実装コストのバランス
2. 要件の完全性(WHY, WHAT, WHO, WHEN)
3. 実現可能性と工数の妥当性
4. 既存機能との整合性・影響範囲
5. 計測可能な成功指標(KPI)の設定
6. ユーザー体験への影響

必須チェック項目:
- [ ] ユーザーストーリーが明確
- [ ] 受け入れ基準が定義されている
- [ ] 成功指標(KPI)が設定されている
- [ ] 技術的制約が考慮されている
- [ ] 優先順位の根拠が明確

出力形式:
## 要件評価

### 総合評価: [承認/条件付き承認/修正要求/却下]

### ビジネス価値: [High/Medium/Low]
{評価理由}

### 実現可能性: [High/Medium/Low]
{評価理由}

### 推奨優先順位: [P0/P1/P2/P3]
{根拠}

### 成功指標(KPI)
{具体的な指標}

### リスクと軽減策
{リスク項目とその対策}

### フィードバック
{具体的な指摘事項}
```

#### 3.2.4 設計レビュー役AI (Senior Engineer - Design)

**トリガー条件:**
- Issueラベル追加時(label: `design-review-requested`)
- Pull Requestの説明文に設計ドキュメントが含まれる場合

**入力データ:**
- 設計ドキュメント(アーキテクチャ図、データモデル、API仕様など)
- 既存のシステム設計
- 要件定義書
- 技術スタック情報

**処理内容:**
1. アーキテクチャの妥当性評価
2. データモデルの評価
3. API設計の評価
4. スケーラビリティの考慮
5. セキュリティの観点
6. 保守性の観点

**出力:**
- Issueコメント
  - 設計の評価
  - 改善提案
  - 懸念事項
  - 代替アプローチの提案

**AI プロンプト設計:**
```
役割: 15年以上の経験を持つシニアエンジニア(システムアーキテクト)

専門領域:
- システムアーキテクチャ設計
- データベース設計
- API設計
- パフォーマンスチューニング

レビュー観点:
1. **アーキテクチャ**
   - レイヤー分離の適切性
   - 責務の分離(SoC)
   - 依存関係の方向性
   - 拡張性・保守性

2. **データモデル**
   - 正規化の適切性
   - インデックス設計
   - リレーションシップの妥当性
   - パフォーマンスへの影響

3. **API設計**
   - RESTful原則の遵守
   - エンドポイント設計
   - リクエスト/レスポンス形式
   - エラーハンドリング
   - バージョニング戦略

4. **非機能要件**
   - スケーラビリティ
   - パフォーマンス
   - セキュリティ
   - 可用性

5. **設計原則**
   - SOLID原則
   - DRY原則
   - YAGNI原則
   - 適切な抽象化

レビュースタイル:
- 建設的で教育的なフィードバック
- 「なぜ」を説明する
- 具体的な改善案を提示
- ベストプラクティスの紹介
- トレードオフの説明

出力形式:
## 設計レビュー

### 総合評価: [承認/条件付き承認/修正要求]

### アーキテクチャ
{評価とフィードバック}

### データモデル
{評価とフィードバック}

### API設計
{評価とフィードバック}

### 懸念事項
- {具体的な懸念点}

### 改善提案
- {具体的な改善案}

### 参考資料
- {関連するベストプラクティスやドキュメント}
```

#### 3.2.5 コードレビュー役AI (Senior Engineer - Code)

**トリガー条件:**
- Pull Request作成時
- Pull Requestへの新規commit追加時

**入力データ:**
- PR diff
- 変更されたファイル一覧
- 既存のコードベース(関連部分)
- テストコード
- PR説明文

**処理内容:**
1. コード品質の評価
2. バグやセキュリティリスクの検出
3. パフォーマンス問題の指摘
4. テストカバレッジの確認
5. コーディング規約の遵守確認
6. 改善提案

**出力:**
- PRレビューコメント(行単位またはファイル単位)
- 総合評価コメント
- 承認/変更要求/コメント

**AI プロンプト設計:**
```
役割: 15年以上の経験を持つシニアエンジニア(コードレビュアー)

専門領域:
- コード品質管理
- セキュリティ
- パフォーマンス最適化
- テスト戦略

レビュー観点:

1. **コード品質**
   - 可読性(命名、コメント、構造)
   - 保守性(複雑度、依存関係)
   - 一貫性(コーディングスタイル)
   - DRY原則の遵守

2. **ロジック**
   - 正確性(バグの可能性)
   - エッジケースの処理
   - エラーハンドリング
   - 境界条件のチェック

3. **パフォーマンス**
   - アルゴリズムの効率性
   - データベースクエリの最適化
   - N+1問題の有無
   - メモリ使用量

4. **セキュリティ**
   - SQLインジェクション対策
   - XSS対策
   - 認証・認可の適切性
   - 機密情報の扱い

5. **テスト**
   - テストカバレッジ
   - テストケースの適切性
   - モックの使用
   - テストの可読性

6. **設計原則**
   - SOLID原則
   - 適切な抽象化
   - 責務の分離
   - インターフェースの設計

レビュースタイル:
- 建設的で教育的
- 問題点だけでなく良い点も指摘
- 「なぜ」問題なのかを説明
- 具体的な改善コードを提示(可能な場合)
- 優先度を明示(Critical/Major/Minor/Nit)

重要度の定義:
- **Critical**: セキュリティ、データ損失、クラッシュなど
- **Major**: バグ、パフォーマンス問題、設計上の大きな問題
- **Minor**: コード品質、保守性の改善
- **Nit**: スタイル、命名などの軽微な指摘

出力形式:
## コードレビュー総合評価

### 判定: [承認/変更要求/コメント]

### 良い点 👍
- {具体的に良かった点}

### 改善が必要な点

#### Critical Issues
- {重大な問題}

#### Major Issues
- {主要な問題}

#### Minor Issues
- {軽微な問題}

### 学習ポイント 📚
{このレビューから学べること}

---

## 個別コメント
{ファイル・行ごとの詳細コメント}
```

#### 3.2.6 仕様書更新AI (Documentation Agent)

**トリガー条件:**
- Pull Requestマージ時

**入力データ:**
- マージされたPRの情報(title, body, diff)
- 現在のプロダクト仕様書(SPECIFICATION.md)
- Issueの内容(元の要望)

**処理内容:**
1. 変更内容の分析
2. 仕様書への反映内容の決定
3. 仕様書の更新(構造を維持)
4. 変更履歴の追加

**出力:**
- 更新されたSPECIFICATION.md
- 変更サマリー(commitメッセージ)

**AI プロンプト設計:**
```
役割: テクニカルライター(ドキュメンテーション専門家)

タスク:
マージされたPRの内容を分析し、プロダクト仕様書を更新してください。

入力:
- 現在の仕様書: {current_spec}
- PRタイトル: {pr_title}
- PR説明: {pr_body}
- 変更内容: {diff_summary}
- 元のIssue: {original_issue}

更新ルール:
1. 既存の構造とフォーマットを維持
2. 追加機能は適切なセクションに追加
3. 変更された機能は内容を更新
4. バージョン番号を更新
5. 変更履歴セクションにエントリを追加
6. 技術的に正確で明確な表現を使用

仕様書の構造:
# プロダクト仕様書

## バージョン情報
## 概要
## 機能一覧
## API仕様
## データモデル
## 非機能要件
## 変更履歴

出力形式:
完全な仕様書のMarkdown + 変更サマリー(JSON)
```

### 3.3 市場環境シミュレータ

#### 3.3.1 状態管理

**データ構造(market_state.json):**
```json
{
  "phase": 1,
  "user_count": 100,
  "merged_prs_count": 0,
  "last_updated": "2025-01-01T00:00:00Z",
  "performance_requirements": {
    "max_response_time_ms": 500,
    "max_db_queries_per_request": 20,
    "required_test_coverage_percent": 60,
    "max_memory_mb": 512
  },
  "business_metrics": {
    "active_users_daily": 50,
    "churn_rate": 0.05,
    "nps_score": 7.5
  },
  "market_conditions": {
    "competition_level": "low",
    "user_demand": "growing",
    "tech_trends": ["real-time collaboration", "mobile-first"]
  }
}
```

#### 3.3.2 進化ロジック

**フェーズ遷移条件:**
- フェーズ1→2: PRマージ数 >= 3
- フェーズ2→3: PRマージ数 >= 6
- フェーズ3→4: PRマージ数 >= 9
- 以降、3PRごとにフェーズアップ

**フェーズ別の変化:**

| Phase | User Count | Response Time | DB Queries | Test Coverage | Complexity |
|-------|-----------|---------------|------------|---------------|------------|
| 1-2   | 100-200   | 500ms        | 20         | 60%           | Low        |
| 3-4   | 400-800   | 400ms        | 15         | 70%           | Medium     |
| 5-6   | 1,600-3,200 | 300ms      | 12         | 75%           | High       |
| 7-8   | 6,400-12,800 | 200ms     | 10         | 80%           | Very High  |
| 9+    | 25,600+   | 150ms        | 8          | 85%           | Extreme    |

**市場条件の変化:**
- 初期(Phase 1-3): 安定した環境、シンプルな要求
- 成長期(Phase 4-6): 競合出現、機能要求の複雑化
- 成熟期(Phase 7+): 激しい競争、最適化・統合の要求

#### 3.3.3 更新タイミング
- PRマージ時: merged_prs_count をインクリメント、フェーズ遷移判定
- 週次: business_metrics, market_conditions の更新

### 3.4 パフォーマンス評価システム

#### 3.4.1 評価項目

**レスポンスタイム測定:**
- 全APIエンドポイントの95パーセンタイル
- 主要エンドポイント(タスク一覧、タスク作成)の詳細測定

**データベースパフォーマンス:**
- リクエストあたりのクエリ数
- スロークエリの検出(100ms以上)
- N+1問題の検出

**リソース使用量:**
- メモリ使用量(ピーク値)
- CPU使用率
- データベース接続数

**テストカバレッジ:**
- 行カバレッジ
- 分岐カバレッジ
- 主要機能のカバレッジ

#### 3.4.2 評価基準

```python
def evaluate_performance(metrics, requirements):
    """
    パフォーマンス評価ロジック
    """
    results = {
        "passed": True,
        "items": []
    }
    
    # レスポンスタイム
    if metrics["response_time_p95"] > requirements["max_response_time_ms"]:
        results["passed"] = False
        results["items"].append({
            "category": "response_time",
            "status": "fail",
            "actual": metrics["response_time_p95"],
            "expected": requirements["max_response_time_ms"],
            "severity": "major"
        })
    
    # データベースクエリ数
    if metrics["avg_db_queries"] > requirements["max_db_queries_per_request"]:
        results["passed"] = False
        results["items"].append({
            "category": "db_queries",
            "status": "fail",
            "actual": metrics["avg_db_queries"],
            "expected": requirements["max_db_queries_per_request"],
            "severity": "major"
        })
    
    # テストカバレッジ
    if metrics["test_coverage"] < requirements["required_test_coverage_percent"]:
        results["passed"] = False
        results["items"].append({
            "category": "test_coverage",
            "status": "fail",
            "actual": metrics["test_coverage"],
            "expected": requirements["required_test_coverage_percent"],
            "severity": "minor"
        })
    
    return results
```

#### 3.4.3 レポート形式

PRコメントに以下の形式でレポート:

```markdown
## 🚀 パフォーマンス評価レポート

### 総合判定: ✅ PASS / ❌ FAIL

### 現在のフェーズ要件
- Phase: 3
- 想定ユーザー数: 400
- 要求レスポンスタイム: 400ms以下
- 要求DBクエリ数: 15以下
- 要求テストカバレッジ: 70%以上

---

### 📊 測定結果

#### レスポンスタイム
- 95パーセンタイル: 380ms ✅
- 主要エンドポイント:
  - GET /tasks: 120ms ✅
  - POST /tasks: 250ms ✅
  - GET /tasks/:id: 80ms ✅

#### データベース
- 平均クエリ数: 12 ✅
- スロークエリ検出: 0件 ✅
- N+1問題: なし ✅

#### リソース
- メモリ使用量: 245MB ✅
- CPU使用率: 35% ✅

#### テスト
- カバレッジ: 72% ✅
- テスト実行時間: 8.5秒

---

### 💡 改善提案
{AIによる改善提案(オプション)}

### 📈 トレンド
- 前回比レスポンスタイム: -15ms (改善)
- 前回比クエリ数: +2 (悪化)
```

---

## 4. 開発プロセスフロー

### 4.1 標準的な開発サイクル

```
1. [自動] 顧客役AIが要望をIssue作成
   ↓
2. [手動] ジュニアエンジニアが要求を整理してIssueコメント
   ↓
3. [自動] ビジネス職/ドメインマスター役AIがレビューコメント
   ↓
4. [手動] ジュニアエンジニアが要求を修正・確定
   ↓
5. [手動] ジュニアエンジニアが要件定義を作成(Issueコメントまたはドキュメント)
   Label追加: requirements-defined
   ↓
6. [自動] PdM役AIが要件レビュー
   ↓
7. [手動] ジュニアエンジニアが要件を修正・確定
   ↓
8. [手動] ジュニアエンジニアが設計を作成(設計ドキュメント)
   Label追加: design-review-requested
   ↓
9. [自動] 設計レビュー役AIがレビュー
   ↓
10. [手動] ジュニアエンジニアが設計を修正・確定
    ↓
11. [手動] ジュニアエンジニアが実装開始、Pull Request作成
    ↓
12. [自動] コードレビュー役AIがレビューコメント
    [自動] パフォーマンス評価システムが測定・レポート
    ↓
13. [手動] ジュニアエンジニアがコードを修正
    ↓
14. [手動] ジュニアエンジニアがPRをマージ
    ↓
15. [自動] 仕様書更新AIがSPECIFICATION.mdを更新
    [自動] 市場環境シミュレータが状態を更新
    ↓
16. [自動] 次の週の月曜日に新しい要望が生成される
    ↓
    (サイクル継続)
```

### 4.2 Issue管理

#### ラベル体系

| Label | 用途 | 付与タイミング |
|-------|------|--------------|
| `customer-request` | 顧客要望 | AI生成時 |
| `phase-{N}` | フェーズ番号 | AI生成時 |
| `requirements-defined` | 要件定義完了 | ジュニアエンジニア |
| `design-review-requested` | 設計レビュー要求 | ジュニアエンジニア |
| `design-approved` | 設計承認済み | レビューAI |
| `in-progress` | 実装中 | ジュニアエンジニア |
| `type:feature` | 新機能 | AI生成時 |
| `type:improvement` | 改善 | AI生成時 |
| `type:bug` | バグ | AI生成時 |
| `type:performance` | パフォーマンス | AI生成時 |
| `priority:high` | 高優先度 | AI/PdM |
| `priority:medium` | 中優先度 | AI/PdM |
| `priority:low` | 低優先度 | AI/PdM |

#### Issueテンプレート

**顧客要望用:**
```markdown
## 背景・目的
{なぜこの機能が必要か}

## 具体的な要望内容
{何をしたいか}

## 期待される効果
{これによって何が改善されるか}

## 優先度(顧客視点)
{High/Medium/Low + 理由}

---
*この要望は顧客役AIによって自動生成されました*
*Phase: {N}, 生成日時: {datetime}*
```

### 4.3 Branch戦略

- `main`: 本番相当ブランチ
- `feature/{issue-number}-{brief-description}`: 機能開発ブランチ
- PRは必ず`main`へマージ

### 4.4 コミット規約

```
<type>(<scope>): <subject>

<body>

Refs: #{issue_number}
```

**type:**
- feat: 新機能
- fix: バグ修正
- refactor: リファクタリング
- perf: パフォーマンス改善
- test: テスト追加・修正
- docs: ドキュメント
- chore: その他

---

## 5. 非機能要件

### 5.1 セキュリティ

**API認証:**
- GitHub Actions: GITHUB_TOKEN(自動付与)
- Anthropic API: ANTHROPIC_API_KEY(Secrets管理)

**データ保護:**
- APIキーはSecrets経由でのみアクセス
- ログにセンシティブ情報を出力しない
- PRコメントに個人情報を含めない

### 5.2 コスト管理

**API使用量の最適化:**
- diffの要約(大きすぎる場合は主要部分のみ)
- コンテキストの絞り込み(関連ファイルのみ)
- キャッシュの活用(同じ内容への重複リクエスト防止)

**予算目安:**
- 月額: $20-50(週2-3サイクルの想定)
- 1サイクルあたり: $2-5
  - 顧客要望生成: $0.02-0.10
  - ビジネスレビュー: $0.05-0.15
  - PdMレビュー: $0.05-0.20
  - 設計レビュー: $0.10-0.30
  - コードレビュー: $0.05-0.20
  - 仕様書更新: $0.10-0.30

### 5.3 パフォーマンス

**GitHub Actions実行時間:**
- 顧客要望生成: 2分以内
- 各レビュー処理: 3分以内
- パフォーマンステスト: 5分以内
- 仕様書更新: 2分以内

**API応答時間:**
- Claude APIへのリクエスト: 10-30秒を想定

### 5.4 信頼性

**エラーハンドリング:**
- API呼び出し失敗時のリトライ(最大3回)
- タイムアウト設定(60秒)
- エラー時の通知(GitHub Issueコメント)

**ログ:**
- 各AI処理の実行ログ
- APIリクエスト/レスポンスのサマリー
- エラー詳細

---

## 6. 実装優先順位とマイルストーン

### Phase 1: 基礎構築(Week 1-2)

**目標:** ベースアプリケーションとリポジトリ環境の整備

**成果物:**
- [ ] タスク管理アプリ初期実装
  - [ ] ユーザー認証
  - [ ] タスクCRUD
  - [ ] 基本的なテスト
- [ ] GitHubリポジトリセットアップ
- [ ] README.md, SPECIFICATION.md作成
- [ ] 基本的なCI/CD(テスト実行)

### Phase 2: AI役割の実装(Week 3-5)

**目標:** 主要なAI役割の実装と動作確認

**Week 3:**
- [ ] プロジェクト構造の構築
  - [ ] スクリプトディレクトリ作成
  - [ ] 共通ライブラリ実装(AI呼び出し、GitHub API連携)
- [ ] 顧客役AIの実装
  - [ ] ワークフローファイル
  - [ ] プロンプト設計
  - [ ] Issue生成ロジック

**Week 4:**
- [ ] ビジネス職/ドメインマスター役AIの実装
- [ ] PdM役AIの実装
- [ ] 市場環境シミュレータ(基本版)

**Week 5:**
- [ ] 設計レビュー役AIの実装
- [ ] コードレビュー役AIの実装
- [ ] 統合テストと調整

### Phase 3: 高度な機能(Week 6-7)

**目標:** パフォーマンス評価と仕様書更新の自動化

**Week 6:**
- [ ] パフォーマンス評価システム
  - [ ] 測定スクリプト
  - [ ] 評価ロジック
  - [ ] レポート生成
- [ ] 仕様書更新AIの実装

**Week 7:**
- [ ] 市場環境シミュレータ(完全版)
- [ ] 統合テストと調整
- [ ] ドキュメント整備

### Phase 4: 調整と改善(Week 8+)

**目標:** 実運用開始と継続的改善

- [ ] 初回サイクルの実施
- [ ] AIプロンプトの最適化
- [ ] フィードバックループの改善
- [ ] 難易度バランスの調整

---

## 7. ディレクトリ構造

```
project-root/
├── .github/
│   └── workflows/
│       ├── customer-request.yml          # 顧客要望生成
│       ├── business-review.yml           # ビジネスレビュー
│       ├── pdm-review.yml                # PdMレビュー
│       ├── design-review.yml             # 設計レビュー
│       ├── code-review.yml               # コードレビュー
│       ├── performance-check.yml         # パフォーマンスチェック
│       ├── update-specification.yml      # 仕様書更新
│       └── update-market-state.yml       # 市場状態更新
├── scripts/
│   ├── ai/
│   │   ├── __init__.py
│   │   ├── anthropic_client.py          # Claude API クライアント
│   │   ├── customer_ai.py               # 顧客役AI
│   │   ├── business_ai.py               # ビジネス職AI
│   │   ├── pdm_ai.py                    # PdM AI
│   │   ├── design_reviewer_ai.py        # 設計レビューAI
│   │   ├── code_reviewer_ai.py          # コードレビューAI
│   │   └── documentation_ai.py          # 仕様書更新AI
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── github_helper.py             # GitHub API ヘルパー
│   │   ├── state_manager.py             # 状態管理
│   │   └── prompt_templates.py          # プロンプトテンプレート
│   ├── performance/
│   │   ├── __init__.py
│   │   ├── measure.py                   # パフォーマンス測定
│   │   ├── evaluate.py                  # 評価ロジック
│   │   └── report.py                    # レポート生成
│   ├── market_simulator.py              # 市場シミュレータ
│   └── requirements.txt
├── src/                                  # アプリケーションコード
│   ├── app.py or index.js
│   ├── models/
│   ├── routes/ or controllers/
│   ├── services/
│   └── utils/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
│   └── design/                           # 設計ドキュメント
├── state/                                # 状態ファイル
│   ├── market_state.json
│   ├── business_strategy.json
│   └── development_metrics.json
├── SPECIFICATION.md                      # プロダクト仕様書
├── README.md
├── .env.example
└── .gitignore
```

---

## 8. 環境構築手順

### 8.1 前提条件

- GitHubアカウント
- Anthropic APIアカウントとAPIキー
- Python 3.11+ または Node.js 18+ の開発環境

### 8.2 初期セットアップ

1. **リポジトリ作成:**
   ```bash
   # GitHubで新規リポジトリ作成(Webから)
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Secrets設定:**
   - GitHub リポジトリの Settings > Secrets and variables > Actions
   - `ANTHROPIC_API_KEY` を追加

3. **ベースアプリケーション作成:**
   - AIで初期コード生成
   - 基本的なCRUD機能の実装
   - テストの作成

4. **スクリプトディレクトリ準備:**
   ```bash
   mkdir -p scripts/{ai,utils,performance}
   mkdir -p state docs/design
   touch scripts/requirements.txt
   ```

5. **初期状態ファイル作成:**
   ```bash
   # market_state.json
   echo '{
     "phase": 1,
     "user_count": 100,
     "merged_prs_count": 0,
     "last_updated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
     "performance_requirements": {
       "max_response_time_ms": 500,
       "max_db_queries_per_request": 20,
       "required_test_coverage_percent": 60
     }
   }' > state/market_state.json
   ```

6. **SPECIFICATION.md作成:**
   ```bash
   # 初期テンプレート作成
   touch SPECIFICATION.md
   ```

7. **GitHub Actions ワークフロー設定:**
   - `.github/workflows/`にワークフローファイルを配置
   - 段階的に有効化

---

## 9. 運用ルール

### 9.1 AIレビューへの対応

**承認の場合:**
- 次のステップへ進む
- ラベルを更新

**修正要求の場合:**
- AIの指摘を理解する
- 必要な修正を実施
- 再度レビューをリクエスト

**学習姿勢:**
- AIのフィードバックから学ぶ
- 「なぜ」その指摘があるのかを考える
- 次回以降に活かす

### 9.2 フェーズの進行

**フェーズアップ時:**
- 新しい要求レベルを確認
- パフォーマンス要件の変化に注意
- 既存コードのリファクタリングを検討

**後期フェーズ(7+)での注意点:**
- 技術的負債が蓄積している可能性
- 大規模リファクタリングが必要になることも
- 段階的な改善を心がける

### 9.3 学習記録

**推奨事項:**
- 各サイクルで学んだことをメモ
- 失敗から学ぶ(レビュー指摘の傾向など)
- 定期的に振り返り

---

## 10. 拡張可能性

### 10.1 将来的な拡張案

**追加AI役割:**
- QAエンジニア役(テスト戦略レビュー)
- セキュリティエンジニア役(脆弱性診断)
- DevOpsエンジニア役(インフラレビュー)
- UX/UIデザイナー役(ユーザー体験レビュー)

**高度な機能:**
- 複数の開発者でのコラボレーションシミュレーション
- 障害・インシデント対応のシミュレーション
- レガシーコード改善のシミュレーション
- マイクロサービス化のシミュレーション

**分析機能:**
- 開発速度の可視化
- コード品質トレンド
- AI指摘内容の分析
- 学習進捗の可視化

### 10.2 他の学習者への展開

- テンプレートリポジトリとして公開
- 学習ガイドの作成
- コミュニティでの知見共有

---

## 11. 成功の定義と評価指標

### 11.1 学習目標の達成度

**技術スキル:**
- [ ] 要求分析・要件定義の能力向上
- [ ] 設計スキルの向上
- [ ] コード品質の向上
- [ ] パフォーマンスチューニングスキル
- [ ] テスト設計スキル

**プロセス理解:**
- [ ] ステークホルダーの視点理解
- [ ] トレードオフの判断能力
- [ ] 技術的負債の理解
- [ ] スケーラビリティの考慮

### 11.2 定量的指標

- フェーズ進行数(目標: Phase 10以上)
- AI承認率の向上(初期30% → 後期70%+)
- パフォーマンス要件達成率
- レビュー指摘件数の減少
- 実装速度の向上

### 11.3 定性的評価

- AIフィードバックの質の変化
- 自己評価による成長実感
- 実プロジェクトへの応用可能性

---

## 12. トラブルシューティング

### 12.1 よくある問題と対処法

**AI APIエラー:**
- レート制限: リトライ間隔を調整
- タイムアウト: コンテキストサイズを削減
- APIキーエラー: Secrets設定を確認

**GitHub Actions失敗:**
- ログを確認
- ワークフロー構文チェック
- 権限設定の確認

**パフォーマンステスト失敗:**
- ローカルで再現
- ボトルネックの特定
- 段階的な最適化

### 12.2 サポートリソース

- Anthropic API Documentation
- GitHub Actions Documentation
- コミュニティフォーラム(将来的に)

---

## 付録

### A. API仕様

#### Anthropic Claude API

**使用モデル:**
- `claude-sonnet-4-5-20250929`

**主要パラメータ:**
```python
{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 4000,  # レビュー用
    "temperature": 0.7,
    "system": "{role_specific_prompt}",
    "messages": [
        {
            "role": "user",
            "content": "{context}"
        }
    ]
}
```

### B. データスキーマ

#### market_state.json

```json
{
  "phase": "integer",
  "user_count": "integer",
  "merged_prs_count": "integer",
  "last_updated": "ISO8601 datetime",
  "performance_requirements": {
    "max_response_time_ms": "integer",
    "max_db_queries_per_request": "integer",
    "required_test_coverage_percent": "integer",
    "max_memory_mb": "integer"
  },
  "business_metrics": {
    "active_users_daily": "integer",
    "churn_rate": "float",
    "nps_score": "float"
  },
  "market_conditions": {
    "competition_level": "low|medium|high",
    "user_demand": "declining|stable|growing",
    "tech_trends": ["string"]
  }
}
```

#### development_metrics.json

```json
{
  "total_issues": "integer",
  "total_prs": "integer",
  "merged_prs": "integer",
  "avg_cycle_time_days": "float",
  "ai_approval_rate": "float",
  "performance_pass_rate": "float",
  "by_phase": {
    "phase_number": {
      "issues": "integer",
      "prs": "integer",
      "avg_review_iterations": "float"
    }
  }
}
```

### C. プロンプトテンプレート集

各AI役割の詳細プロンプトは`scripts/utils/prompt_templates.py`に実装。

### D. コーディング規約

**Python:**
- PEP 8準拠
- 型ヒントの使用
- Docstring(Google形式)

**Node.js:**
- ESLint + Prettier
- JSDoc
- async/awaitの使用

**共通:**
- 意味のある変数名
- 関数は単一責任
- 適切なコメント

---

## バージョン情報

- **文書バージョン:** 1.0
- **作成日:** 2025-01-XX
- **最終更新日:** 2025-01-XX
- **作成者:** AI開発支援システム

---

## 変更履歴

| 日付 | バージョン | 変更内容 | 作成者 |
|------|----------|---------|--------|
| 2025-01-XX | 1.0 | 初版作成 | - |

---

**この要件定義書は、Claude Codeでの実装を想定して作成されています。**
**実装時には、段階的に機能を追加し、各フェーズで動作確認を行うことを推奨します。**