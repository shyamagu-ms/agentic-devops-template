---
description: '全成果物作成ワークフローは、提供された指示ファイル群に従い一気通貫に成果物を作成します。'
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'microsoft-docs/*', 'agent', 'azure-mcp/*', 'mermaidchart.vscode-mermaid-chart/get_syntax_docs', 'mermaidchart.vscode-mermaid-chart/mermaid-diagram-validator', 'todo']
---
# 全成果物作成ワークフロー

以下の8ステップで順番に処理を実施します。並列に実行せずに、一つ一つサブエージェントの結果を待ってから次に進んでください。

## 1. GitHub Spark成果物のローカル化

[GitHub Sparkフロントエンドコード改修ワークフロー](./0_adjust_github_sparck_code.prompt.md)を、Opus4.5 サブエージェントで実行する。

## 2. 要件定義書の作成

[要件定義書作成ワークフロー](./1_create_requirements_from_spark_artifact.prompt.md)を、Opus4.5 サブエージェントで実行する。

## 3. 設計書の作成

[設計書作成ワークフロー](./2_create_design_workflow.prompt.md)を、Opus4.5 サブエージェントで実行する。

GPT-5.2-Codex サブエージェントを利用して、要件定義書と設計書に齟齬がないかレビューする。指摘がある場合、直接ファイルを編集すること。

## 4. インフラストラクチャ実装の作成

[インフラストラクチャ実装ワークフロー](./3_create_code_infra_workflow.prompt.md)を、Opus4.5 サブエージェントで実行する。

## 5. データベース実装の作成

[データベース実装ワークフロー](./4_create_code_data_workflow.prompt.md)を、Opus4.5 サブエージェントで実行する。

## 6. バックエンド実装の作成

[バックエンド実装ワークフロー](./5_create_code_back_workflow.prompt.md)を、Opus4.5 サブエージェントで実行する。

## 7. フロントエンド実装の改修

[フロントエンド実装ワークフロー](./6_update_code_front_workflow.prompt.md)を、Opus4.5 サブエージェントで実行する。

## 8. ローカル実行の確認

[ローカル実行ワークフロー](./7_local_run_with_emulator.prompt.md)を、Opus4.5 サブエージェントで実行する。

