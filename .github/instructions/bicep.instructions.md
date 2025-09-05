---
description: "Infrastructure as Code with Bicep"
applyTo: "**/*.bicep"
---

## 命名と記法（Bicep）
  - パラメータ/変数/リソースのシンボリック名はlowerCamelCase。nameという語は避ける（リソース自体を表すため）
  - 変数とパラメータを接尾辞で区別しない。説明的なシンボリック名を使う（storageAccount, appServicePlan等）

## 構造/宣言
  - パラメータはファイル先頭に配置し@description、minLength/maxLengthを付与
  - モジュール化: main → network/database/app/shared/monitor 等に分割
  - コメントで意図・前提・例外を明記

## APIバージョン
  - 全リソースで最新安定版APIを使用。例外時はコメントで理由と期限を明示
  - az provider show やドキュメントで定期確認し、更新は検証後反映

## パラメータ運用
  - 既定値は低コスト（検証向け）。@allowedは最小限
  - 供給は原則 .bicepparam（環境別）。優先順位: パイプライン変数 > .bicepparam > Bicepデフォルト

## 変数/式
  - 複雑な式は変数化して可読性を確保
  - 共通tagsはオブジェクトで全モジュールへ渡し、一括適用

## 参照と依存
  - 依存はシンボリック参照（resourceA.id）で表現。dependsOnは最小限
  - 既存リソースはexistingを使用し、値の受け回しを避ける
  - スコープ越えはtargetScope/module scopeを明示

## リソース名の実装（設計の命名規則をコード化）
  - ハイフン可の種類: "<abbr>-<org>-<workload>-<env>-<region>-<nnn>"
  - ハイフン不可の種類（例: Storage Account）:
    - 連結形式で英字開始。必要に応じuniqueString(...)の短いサフィックスを付加
    - 長さ超過はsubstringで調整（例: 24文字以内）
    - 例サフィックスのseed例: subscription().subscriptionId, resourceGroup().id, workload
  - グローバル一意が必要な種類は、英字接頭辞＋短いuniqueStringで衝突回避

 ### 代表的略称（CAFの公式略称を採用）
  - rg（リソースグループ）、vnet、snet（サブネット）、nsg、kv、st（Storage Account）、sql（SQL Server/Logical）、sqldb（SQL DB）、vm、nic、pip、agw（App Gateway）、afw（Azure Firewall）、law（Log Analytics WS）、appi（App Insights）
  - 地域コード（例）
    - japaneast=jpe、japanwest=jpw（他地域はCAF地域コードに準拠）
  - 例
    - リソースグループ: rg-orgx-projx-dev-jpe-001

## 子リソース
  - parentまたはネストを用い、手組みのname連結を避ける。過度なネストは避ける

## セキュリティ
  - シークレット/キーを出力しない。Key VaultはRBACでMIに必要最小ロール（例: Key Vault Secrets User）
  - Data Plane権限（Storage Blob Data Contributor等）はMIへ付与

## 診断/監視の実装
  - 主要リソースでDiagnostic Settingsを有効化し、Log Analyticsへ送信（ワークスペースIDはパラメータ化）
  - Action Groupとアラートルールをコード化し、しきい値はパラメータ化

## ドキュメント/可読性
  - // コメントで意図・例外・API固定理由・将来TODOを明記
  - 出力はID/エンドポイント等の非機密に限定

## ディレクトリ例
  - infra/main.bicep
  - infra/modules/network.bicep, database.bicep, app.bicep, shared.bicep, monitor.bicep
  - infra/parameters/dev.bicepparam, stg.bicepparam, prod.bicepparam
  - infra/bicepconfig.json（linter有効）

## パイプライン実装
  - ジョブ: lint/build → what-if → 承認 → deploy → smoke test
  - 認証: OIDCでサブスクへ（対象RG Contributor）。デプロイはaz deployment sub/rg create（incremental）
  - ロールバック: 直前安定版コミットを再デプロイ（IaCを唯一の真実源とする）
