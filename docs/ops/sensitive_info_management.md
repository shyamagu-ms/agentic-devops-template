---
post_title: 機微情報の検索と対処ガイド
author1: システム管理者
tags: [セキュリティ, 機微情報, コンプライアンス, パブリックリポジトリ]
ai_note: true
summary: パブリックリポジトリ公開前の機微情報スキャンと対処方法に関するガイドライン
post_date: 2025-09-05
---

# 機微情報の検索と対処ガイド

## 概要

パブリックリポジトリとして公開する前に、機微情報（センシティブ情報）が含まれていないかを確認し、適切に処理する必要があります。このドキュメントでは、機微情報の検索方法と対処方法について説明します。

## 機微情報の定義

以下の情報は機微情報として取り扱い、パブリックリポジトリから除外する必要があります：

### 認証情報
- パスワード、パスフレーズ
- APIキー、アクセストークン
- 秘密鍵、証明書
- データベース認証情報

### 個人情報
- 実際のメールアドレス（公式ドキュメント以外）
- 電話番号、住所
- 個人名（作者情報以外）

### システム情報
- 本番環境のIPアドレス、ドメイン名
- データベース接続文字列
- Azure/AWS等のサブスクリプションID、テナントID
- リソースグループ名、実際のリソース名

### 組織情報
- 内部システムの詳細構成
- 内部ネットワーク情報
- 組織固有のビジネスロジック詳細

## 機微情報スキャンツール

### 自動スキャンスクリプト

```bash
# 機微情報スキャンの実行
./scripts/scan_sensitive_info.sh
```

このスクリプトは以下の項目をチェックします：
1. パスワード・シークレット・トークン・キー・認証情報
2. API キーパターン（Base64、AWS、Google等）
3. メールアドレス（公式以外）
4. 外部IPアドレス
5. データベース接続文字列
6. Azure リソース固有識別子

### 手動チェックポイント

自動スキャンに加えて、以下の項目を手動で確認してください：

#### 設定ファイル
- `appsettings.json`, `config.json`
- `.env`, `.env.*` ファイル
- `docker-compose.yml` の環境変数セクション

#### ドキュメント
- READMEファイル内のサンプルコード
- 設計書、手順書内の接続情報
- プロンプトファイル内の例示データ

#### コード
- ハードコードされた認証情報
- テスト用のモックデータ
- コメント内の実際の情報

## 対処方法

### 1. 情報の削除

機微情報が含まれている場合：

```bash
# ファイルから該当箇所を削除
# 例：パスワードをプレースホルダーに置換
sed -i 's/password: "ACTUAL_PASSWORD_HERE"/password: "<YOUR_PASSWORD>"/g' file.txt
```

### 2. 環境変数への移行

ハードコードされた値を環境変数に移行：

```json
// Before (EXAMPLE - DO NOT USE REAL VALUES)
{
  "connectionString": "Server=EXAMPLE.database.com;Database=SAMPLE_DB;User=SAMPLE_USER;Password=SAMPLE_PASSWORD_123;"
}

// After
{
  "connectionString": "${CONNECTION_STRING}"
}
```

### 3. 設定ファイルのテンプレート化

実際の設定ファイルを除外し、テンプレートを提供：

```
# .gitignoreに追加
appsettings.json
.env

# テンプレートファイルを作成
appsettings.template.json
.env.example
```

### 4. ドキュメントの sanitization

```markdown
<!-- Before (EXAMPLE) -->
データベース: EXAMPLE-COMPANY-prod-db.database.windows.net

<!-- After -->
データベース: <YOUR_DATABASE_SERVER>.database.windows.net
```

## .gitignoreの推奨設定

機微情報を含む可能性のあるファイルを自動的に除外：

```gitignore
# 認証情報
*.key
*.pem
*.p12
*.pfx

# 設定ファイル
appsettings.json
appsettings.*.json
.env
.env.*
config.json

# ログファイル
*.log
logs/

# 一時ファイル
temp/
tmp/
.DS_Store
Thumbs.db

# IDEファイル
.vscode/settings.json
.idea/

# 機微情報スキャン結果
scripts/sensitive_info_scan_report.txt
```

## 継続的な監視

### Pre-commit フック

```bash
#!/bin/sh
# .git/hooks/pre-commit

# 機微情報スキャンを実行
if ./scripts/scan_sensitive_info.sh; then
  echo "機微情報スキャン: OK"
else
  echo "機微情報が検出されました。コミットを中止します。"
  exit 1
fi
```

### GitHub Actions

```yaml
name: 機微情報チェック
on: [push, pull_request]
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: 機微情報スキャン
        run: ./scripts/scan_sensitive_info.sh
```

## チェックリスト

パブリックリポジトリ公開前に以下を確認：

- [ ] 機微情報スキャンスクリプトの実行
- [ ] 手動での設定ファイル確認
- [ ] ドキュメント内の実際の情報削除
- [ ] .gitignoreの設定
- [ ] 環境変数テンプレートの作成
- [ ] テスト用データの匿名化
- [ ] コミット履歴に機微情報が含まれていないか確認

## 参考資料

- [GitHub: Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [OWASP: Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [Microsoft: Keep credentials out of code](https://docs.microsoft.com/en-us/azure/devops/repos/git/remove-credentials?view=azure-devops)