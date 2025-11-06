# プロダクト仕様書

## バージョン情報
- バージョン: 0.1.0
- 最終更新日: 2025-01-01
- 作成者: AI開発支援システム

## 概要
AI役割を活用した開発プロセスシミュレーション環境のベースとなるタスク管理アプリケーション。Ruby on Rails 7をベースにし、ユーザー認証、タスク管理、API、パフォーマンス計測を段階的に学習できるようにする。

## 機能一覧
1. ユーザー認証 (メール/パスワード, セッション管理)
2. タスクCRUD (タイトル、説明、期限、優先度、完了フラグ)
3. RESTful API (JSON)
4. 管理ダッシュボード (今後追加予定)

## API仕様
| メソッド | パス | 概要 |
|----------|------|------|
| GET | /tasks | タスク一覧取得 (フィルタ・ソート)
| POST | /tasks | タスク作成
| GET | /tasks/:id | タスク詳細
| PATCH | /tasks/:id | タスク更新
| DELETE | /tasks/:id | タスク削除
| POST | /sessions | ログイン
| DELETE | /sessions | ログアウト

## データモデル
### users
| カラム | 型 | 説明 |
|--------|----|------|
| id | bigint | PK |
| email | string | ユニーク制約 |
| password_digest | string | BCrypt |
| created_at | datetime | |
| updated_at | datetime | |

### tasks
| カラム | 型 | 説明 |
|--------|----|------|
| id | bigint | PK |
| user_id | bigint | FK(users) |
| title | string | 必須 |
| description | text | |
| due_at | datetime | 期限 |
| priority | integer | 0=low,1=medium,2=high |
| completed | boolean | default: false |
| created_at | datetime | |
| updated_at | datetime | |

## 非機能要件
- 95パーセンタイル500ms以下 (Phase 1)
- 1リクエストあたりDBクエリ20以下
- テストカバレッジ60%以上

## 変更履歴
| 日付 | バージョン | 概要 |
|------|------------|------|
| 2025-01-01 | 0.1.0 | 初版作成 |

