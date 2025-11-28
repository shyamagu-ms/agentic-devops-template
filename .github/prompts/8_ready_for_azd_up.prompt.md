---
description: 'Azd Up準備ワークフローは、これまでの成果をもとにazd upで一括でデプロイする準備を行います'
tools: ['edit', 'changes', 'search', 'extensions', 'fetch', 'githubRepo', 'openSimpleBrowser', 'problems', 'runTasks', 'search', 'todos', 'runCommands',  'testFailure', 'usages', 'vscodeAPI', 'microsoft-docs/*', 'Azure MCP/*']
---

Azd UP準備ワークフローは、現在の構成でAzd Upをユーザが実行するための準備を行い、手順書を作成します。

## 作成する成果物
 - **`/.azure`** Azureの構成や環境に関する情報
 - **`azure.yaml`** Azureの設定ファイル
 - **`/docs/ops/azd-deployment.md`** Azd Up用のデプロイメント手順書

## デプロイ構成
 - **`/back`** バックエンド実装はAzure Functionsにデプロイされます
  - バックエンドはAzure Storageと、Azure SQL DBを利用します。適切なManaged Identity認証が必要です。
 - **`/front`** フロントエンド実装はAzure Static Web Appsにデプロイされます。この際`/back`はBYOでAPIとして定義します。
 - **`/infra`** Bicep実装のインフラストラクチャ定義です
 - **`/data`** Azure SQLDBに投入すべきテーブル定義・初期データが実行スクリプトともに入っています

## 参照・更新すべきドキュメント
 - **`/docs`** システム全体の設計やAPI仕様書などのドキュメントが含まれています。変更がある場合反映します。

## 履歴的記録 (/docs//impl/history配下)
 - **実装記録**: `/docs/impl/history配下/` - 各実装の決定記録や一時的な分析文書など

# デプロイ準備ワークフロー

**常に最新情報を取得する**
マイクロソフトAzureやGitHubテクノロジーに関して記載する場合は、ツール'microsoft-docs'や'Azure MCP'を使用して最新情報を取得し、最新で正確な全情報を読み込むこと。

**ステップをスキップしない。一貫した用語を使用する。曖昧さを減らす。**

**重要なプロセス制約:**
- **各フェーズ完了時に次フェーズへの進行について合意を得る**
- ユーザーの承認なしに次のフェーズに自動的に進まない
- フェーズ間の移行では明確なチェックポイントを提示する
- 不完全なフェーズでの進行を防ぐための確認プロセスを実施する

## 1.分析
 - 最終的にAzd upで一括デプロイできるようにするために、足りない記載や不足している要素を既存成果物から洗い出します
 - infra/data/back/front の順に確認します
  - 各フォルダに格納されているdeployment.mdを確認し、修正が必要であれば実施します。
  - infra成果物にあるbicepは実ビルドの成功まで確認がとれています。

## 2.対応
 - 分析フェーズで設定や実装不整合や不備があれば対応します。
 - 不足している情報があれば都度ユーザに確認を求めます。
  - **最終的にパラメータを外だしできる設定は、外だし後にデプロイガイドに記載をしてください。**

## 3. Azure Developer CLI 準備
 - `/.azure`や`azure.yaml`を作成します。
 - `/docs/ops/azd-deployment.md`を用意し、ユーザがAzd Upできるようにします。




