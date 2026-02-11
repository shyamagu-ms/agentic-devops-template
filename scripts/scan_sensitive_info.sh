#!/bin/bash

# 機微情報スキャンスクリプト
# パブリックリポジトリの公開前に実行し、機微情報が含まれていないかチェックする

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$REPO_ROOT/scripts/sensitive_info_scan_report.txt"

echo "==============================================" > "$OUTPUT_FILE"
echo "機微情報スキャン結果 - $(date)" >> "$OUTPUT_FILE"
echo "==============================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

cd "$REPO_ROOT"

# カウンター
TOTAL_ISSUES=0

echo "機微情報スキャンを開始しています..."
echo "結果は $OUTPUT_FILE に出力されます。"

# 1. パスワード・シークレット・トークン・キー・認証情報の検索
echo "1. パスワード・シークレット・トークン・キー・認証情報をチェック中..."
echo "## 1. パスワード・シークレット・トークン・キー・認証情報" >> "$OUTPUT_FILE"
MATCHES=$(grep -r -i -n "password\|secret\|token\|key\|credential" . --exclude-dir=.git --exclude-dir=node_modules --exclude="$OUTPUT_FILE" --exclude="$(basename "$0")" | grep -v -E "(keyof|keyword|keypad|keystone|keystroke|#.*key|//.*key|<!--.*key|template|example|sample|guide|instruction|placeholder|key vault|keyvault|key functions|environment.*key|環境変数.*key|key.*functions|key.*variables|EXAMPLE|SAMPLE|gitignore|\.key|secrets\.json|OWASP|cheatsheet)" || true)
if [ -n "$MATCHES" ]; then
    echo "$MATCHES" >> "$OUTPUT_FILE"
    COUNT=$(echo "$MATCHES" | wc -l)
    TOTAL_ISSUES=$((TOTAL_ISSUES + COUNT))
else
    echo "問題なし" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 2. Base64エンコードされたキー、AWSアクセスキー、Google APIキーなどの検索
echo "2. API キーパターンをチェック中..."
echo "## 2. API キーパターン（Base64、AWS、Google等）" >> "$OUTPUT_FILE"
MATCHES=$(grep -r -E -n "([A-Za-z0-9+/]{40,}=*|[A-Z0-9]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z\-_]{35})" . --exclude-dir=.git --exclude-dir=node_modules --exclude="$OUTPUT_FILE" --exclude="$(basename "$0")" | grep -v -E "(template|example|sample|guide|instruction|placeholder|#|//|<!--)" || true)
if [ -n "$MATCHES" ]; then
    echo "$MATCHES" >> "$OUTPUT_FILE"
    COUNT=$(echo "$MATCHES" | wc -l)
    TOTAL_ISSUES=$((TOTAL_ISSUES + COUNT))
else
    echo "問題なし" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 3. メールアドレスの検索（実際のメールアドレスのみ）
echo "3. メールアドレスをチェック中..."
echo "## 3. メールアドレス" >> "$OUTPUT_FILE"
MATCHES=$(grep -r -E -n "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}" . --exclude-dir=.git --exclude-dir=node_modules --exclude="$OUTPUT_FILE" --exclude="$(basename "$0")" | grep -v -E "(example\.com|test\.com|sample\.com|placeholder|template|@microsoft\.com|@github\.com|learn\.microsoft)" || true)
if [ -n "$MATCHES" ]; then
    echo "$MATCHES" >> "$OUTPUT_FILE"
    COUNT=$(echo "$MATCHES" | wc -l)
    TOTAL_ISSUES=$((TOTAL_ISSUES + COUNT))
else
    echo "問題なし" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 4. 外部IPアドレスの検索（ローカルホスト以外）
echo "4. 外部IPアドレスをチェック中..."
echo "## 4. 外部IPアドレス" >> "$OUTPUT_FILE"
MATCHES=$(grep -r -E -n "([0-9]{1,3}\.){3}[0-9]{1,3}" . --exclude-dir=.git --exclude-dir=node_modules --exclude="$OUTPUT_FILE" --exclude="$(basename "$0")" | grep -v -E "(127\.0\.0\.1|localhost|0\.0\.0\.0|192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|template|example)" || true)
if [ -n "$MATCHES" ]; then
    echo "$MATCHES" >> "$OUTPUT_FILE"
    COUNT=$(echo "$MATCHES" | wc -l)
    TOTAL_ISSUES=$((TOTAL_ISSUES + COUNT))
else
    echo "問題なし" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 5. データベース接続文字列の検索
echo "5. データベース接続文字列をチェック中..."
echo "## 5. データベース接続文字列" >> "$OUTPUT_FILE"
MATCHES=$(grep -r -E -n "(jdbc:|mongodb:|postgresql:|mysql:|Server=|Data Source=|Initial Catalog=)" . --exclude-dir=.git --exclude-dir=node_modules --exclude="$OUTPUT_FILE" --exclude="$(basename "$0")" | grep -v -E "(localhost|template|example|sample|guide|instruction|EXAMPLE|SAMPLE)" || true)
if [ -n "$MATCHES" ]; then
    echo "$MATCHES" >> "$OUTPUT_FILE"
    COUNT=$(echo "$MATCHES" | wc -l)
    TOTAL_ISSUES=$((TOTAL_ISSUES + COUNT))
else
    echo "問題なし" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 6. 実際のAzure リソース名や固有識別子の検索
echo "6. Azureリソース固有識別子をチェック中..."
echo "## 6. Azure リソース固有識別子" >> "$OUTPUT_FILE"
MATCHES=$(grep -r -E -n "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" . --exclude-dir=.git --exclude-dir=node_modules --exclude="$OUTPUT_FILE" --exclude="$(basename "$0")" | grep -v -E "(template|example|sample|guide|instruction|placeholder)" || true)
if [ -n "$MATCHES" ]; then
    echo "$MATCHES" >> "$OUTPUT_FILE"
    COUNT=$(echo "$MATCHES" | wc -l)
    TOTAL_ISSUES=$((TOTAL_ISSUES + COUNT))
else
    echo "問題なし" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 結果サマリー
echo "==============================================" >> "$OUTPUT_FILE"
echo "スキャン結果サマリー" >> "$OUTPUT_FILE"
echo "==============================================" >> "$OUTPUT_FILE"
echo "検出された潜在的機微情報: $TOTAL_ISSUES 件" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo "✅ 機微情報は検出されませんでした。" >> "$OUTPUT_FILE"
    echo "✅ 機微情報スキャン完了: 問題なし"
    exit 0
else
    echo "⚠️ 潜在的な機微情報が検出されました。" >> "$OUTPUT_FILE"
    echo "詳細を確認し、必要に応じて修正してください。" >> "$OUTPUT_FILE"
    echo "⚠️ 機微情報スキャン完了: $TOTAL_ISSUES 件の潜在的問題が検出されました"
    echo "詳細は $OUTPUT_FILE を確認してください。"
    exit 1
fi