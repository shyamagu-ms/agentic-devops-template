---
description: 'ローカル実行ワークフローは、エミュレーターを利用し、ローカル環境での動作確認を行います。'
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'microsoft-docs/*', 'agent', 'azure-mcp/*', 'todo']
---
# ローカル実行ワークフロー

ユーザとインタラクティブにガイドしながら、ローカル実行環境を構築・実行する

## 目的
 1. バックエンドサービス(/back)を、SQLDBとStroageのエミュレータを利用しローカル実行する(/dataを利用する)
 2. フロントエンドアプリケーション(/front)を、Azure Static Web Appsのエミュレータを利用しローカル実行する(1.のバックエンドサービスを利用する)
 3. 上記の手順を文書化(/docs/ops/local_deployment.md)する

## 参照する情報
 - [バックエンドサービスデプロイ手順](../../back/deployment.md)
 - [データベースデプロイ手順](../../data/deployment.md)
 - [フロントエンドサービスデプロイ手順](../../front/deployment.md)

**参照した資料に誤りや不足がある場合、当該資料を必ず修正すること**

## エミュレータの情報
Azure Functions/ Azure Static Web Apps エミュレータはコマンド起動すること
SQLDB/ Storage Emulatorのプロセスは起動済みであることを前提とする

### SQL Database Emulator
 - localhost:1438
  - （必要に応じて以下の情報を利用、作成すること）
  - データベース名: 未作成
  - ユーザー名: `sa`
  - パスワード: `P@ssw0rd`

### Blob Storage Emulator (Azurite)
 - Azurite Blob Service: http://127.0.0.1:10000
 - Azurite Queue Service: http://127.0.0.1:10001
 - Azurite Table Service: http://127.0.0.1:10002

### Azure Function Emulator
 - az func start で起動

### Azure Static Web App Emulator
 - swa start で起動