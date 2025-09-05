# インフラストラクチャ（Bicep）の設計ガイドライン

## 基本方針
  - Azure Landing Zone準拠。管理グループでガバナンス（Azure Policy/RBAC）を集中管理
  - すべてBicepでIaC化。モジュール化と再利用を前提

## リソース計画
  - リソース一覧（App/VM/Storage/SQL/KeyVault/VNet等）、冗長化、リージョン（プライマリ/DR）、スケール要件を定義
  - 依存関係とデプロイ順序/並列性を明記（例: VNet→PE→DB→App）

## リソースグループ/階層
  - Hub-Spoke前提。RG例: shared, net, app, data を環境・リージョン単位で分割
  - 例: rg-<org>-shared-<env>-<region>, rg-<org>-<workload>-net-<env>-<region> など

## 命名規則（CAF準拠の具体化）
  - 標準形式: <abbr>-<org>-<workload>-<env>-<region>-<instance>（ハイフン区切り）
  - 例外形式: 連結（ハイフン不可の種類: Storage Accountなど）
  - コンポーネント定義
    - abbr: CAF公式略称（例: rg, vnet, nsg, kv, st, sql, vm, law, agw, pip, nic, snet）
    - org: 組織コード（3–5小文字）
    - workload: 業務/システム名（3–12小文字）
    - env: dev/stg/prod
    - region: CAF地域コード（例: japaneast=jpe, japanwest=jpw）
    - instance: 3桁連番（001開始）
  - 制約対応
    - グローバル一意が必要な種類（例: Storage, Public DNSなど）はuniqueStringの短いサフィックスで調整
    - ハイフン不可や文字制約が厳しい種類（Storage等）は連結形式、英字開始、長さ内に収める
  - 例
    - リソースグループ: rg-orgx-projx-dev-jpe-001
    - VNet: vnet-orgx-projx-dev-jpe-001
    - Key Vault: kv-orgx-projx-prod-jpe-001
    - Storage Account（連結・24字以内・小英数のみ）: storgxprojxprodjpe001u4

## タグ・ガバナンス
  - 必須タグ: Owner, CostCenter, Workload, Environment(dev/stg/prod), Criticality(low/medium/high), DataClass(public/internal/confidential/restricted), ManagedBy=IaC-Bicep, Org, BU(任意)
  - Policyでタグ必須、リージョン制限、診断設定強制を適用（管理グループ単位）

## パラメータ/設定値管理
  - 環境別インフラ設定値一覧を原本にし、.bicepparamへ反映（サブスクID、RG名、VNetアドレス、SKU、タグ等）
  - サブスク差異はパラメータ切替で吸収

## セキュリティ/認証（Entra ID）
  - 認証・認可はEntra IDへ統一。アプリ→下位リソースはManaged Identity（MI）で最小権限付与
  - RBACはグループベース。Dev=Contributor（Dev RG）、Stg/Prod=Reader（原則）、運用=Prod RG Contributor

## Managed Identity方針
  - 既定SystemAssigned。複数リソースで共有/安定ID必要時のみUserAssigned（miu-略）

## Key Vault設計
  - Workload×環境で1つ（shared用は別）。RBACモデル、Soft-delete/Purge保護有効、Firewall+PE、Private DNS
  - シークレット命名: <workload>-<purpose>-<env>（例: projx-sql-cs-prod）

## ネットワーク
  - Hub-Spoke、入口はApp Gateway WAF v2（グローバル配信はFront Door検討）
  - Private Endpoint標準、NSGは既定Deny＋必要最小許可、Private DNSをHubに集約リンク

## 監視/運用
  - Log Analytics Workspaceは環境別集約（shared RG）。保持: dev=30日、stg=60日、prod=90日
  - 既定として、診断設定のメトリックをLog Analytices Workspaceに送信設定する
  - 代表アラート: 役割割当変更、App 5xx率、SQL CPU>80%、Storageスロットリング、Service Health、Budget

## リージョン/DR
  - 既定ペア: jpe⇔jpw、RPO 15分・RTO 4時間。SQLはAuto-failover group、StorageはRA-GRS/GRS、DNS切替手順を明記

## SKU/スケール/コスト
  - dev=低コスト最小、stg=本番近似下位、prod=性能基準。AutoScale: CPU>70% 5分で+1、<40%で-1、上限/下限設定
  - 予算/コストアラートを設定

## デプロイ/パイプライン
  - GitHub Actions（OIDC/Federated）。Lint→What-if→承認→Apply→スモークテスト。モードはincremental
  - プレビュー機能は原則不可。例外はDev/Stg限定、Prod禁止（承認・撤去条件明記）
