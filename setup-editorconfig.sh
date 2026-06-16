#!/usr/bin/env bash
# =============================================================================
# setup-editorconfig.sh
# EditorConfig / Prettier / VS Code 設定ファイルを一括生成するスクリプト
#
# 使い方:
#   1. プロジェクトルートにこのファイルを置く
#   2. Git Bash で実行: bash setup-editorconfig.sh
#
# 生成されるファイル:
#   .editorconfig
#   .gitattributes
#   .vscode/settings.json
#   backend/.editorconfig
#   frontend/.editorconfig
#   frontend/.prettierrc.js
#   frontend/.prettierignore
# =============================================================================

set -e  # エラーが発生したら即終了

echo "=== EditorConfig / Prettier セットアップ開始 ==="

# -----------------------------------------------------------------------------
# ディレクトリ作成
# -----------------------------------------------------------------------------
echo "ディレクトリを作成しています..."
mkdir -p .vscode
mkdir -p backend
mkdir -p frontend

# -----------------------------------------------------------------------------
# ルート: .editorconfig
# -----------------------------------------------------------------------------
echo "作成: .editorconfig"
cat > .editorconfig << 'EOF'
# =============================================================================
# ルート .editorconfig
# すべてのサブディレクトリに適用される共通設定
# backend/.editorconfig / frontend/.editorconfig で上書き可能
# =============================================================================
root = true

# -----------------------------------------------------------------------------
# 全ファイル共通
# -----------------------------------------------------------------------------
[*]
# UTF-8 統一（BOM なし）
charset = utf-8

# 改行コードは LF に統一（Windows 環境での混在を防ぐ）
# .gitattributes も合わせて設定すること
end_of_line = lf

# インデントはスペース（各言語のサブ設定で indent_size を指定）
indent_style = space

# 行末のスペースを自動削除
trim_trailing_whitespace = true

# ファイル末尾に改行を挿入（POSIX 準拠・Git diff をきれいに保つ）
insert_final_newline = true

# -----------------------------------------------------------------------------
# Windows スクリプト系は CRLF のまま
# LF にすると実行時にエラーになるケースがあるため除外
# -----------------------------------------------------------------------------
[*.{bat,cmd,ps1}]
end_of_line = crlf
EOF

# -----------------------------------------------------------------------------
# ルート: .gitattributes
# -----------------------------------------------------------------------------
echo "作成: .gitattributes"
cat > .gitattributes << 'EOF'
# =============================================================================
# .gitattributes
# Git チェックアウト時の改行コードを制御する
# .editorconfig の end_of_line 設定と必ず合わせること
# =============================================================================

# すべてのテキストファイルを LF に統一
# text=auto : Git がテキストファイルと判断したものを対象にする
* text=auto eol=lf

# Windows スクリプトは CRLF のまま（LF にすると実行エラーになるため）
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf
EOF

# -----------------------------------------------------------------------------
# .vscode/settings.json
# -----------------------------------------------------------------------------
echo "作成: .vscode/settings.json"
cat > .vscode/settings.json << 'EOF'
{
  // ---------------------------------------------------------------------------
  // フォーマッター
  // ---------------------------------------------------------------------------

  // デフォルトのフォーマッターを Prettier に設定
  "editor.defaultFormatter": "esbenp.prettier-vscode",

  // ファイル保存時に自動フォーマット
  "editor.formatOnSave": true,

  // ---------------------------------------------------------------------------
  // 言語別フォーマッター上書き
  // ---------------------------------------------------------------------------

  // C# は EditorConfig / C# 拡張に任せる（Prettier は不要）
  "[csharp]": {
    "editor.defaultFormatter": "ms-dotnettools.csharp"
  }
}
EOF

# -----------------------------------------------------------------------------
# backend/.editorconfig
# -----------------------------------------------------------------------------
echo "作成: backend/.editorconfig"
cat > backend/.editorconfig << 'EOF'
# =============================================================================
# backend/.editorconfig
# C# / ASP.NET Core 向け設定
# root = true は書かない → ルートの .editorconfig を継承する
# =============================================================================

# -----------------------------------------------------------------------------
# C# ソースファイル
# -----------------------------------------------------------------------------
[*.cs]
# C# の標準は 4 スペース
indent_size = 4

# --- var の使い方 -------------------------------------------------------------
# int など組み込み型は明示的に型を書く（可読性のため）
csharp_style_var_for_built_in_types = false:warning
# new SomeClass() のように型が明らかな場合は var を許容
csharp_style_var_when_type_is_apparent = true:suggestion
# それ以外は var を使わない
csharp_style_var_elsewhere = false:suggestion

# --- 波括弧 ------------------------------------------------------------------
# if/for 等で波括弧を省略しない（バグ防止）
csharp_prefer_braces = true:warning

# --- 改行スタイル（Allman スタイル）------------------------------------------
# C# の標準的な慣習に従い、波括弧は常に新しい行に置く
csharp_new_line_before_open_brace = all
csharp_new_line_before_else = true
csharp_new_line_before_catch = true
csharp_new_line_before_finally = true

# --- using 整理 --------------------------------------------------------------
# System 系の using を先頭にソート
dotnet_sort_system_directives_first = true
# using グループ間に空行を入れる
dotnet_separate_import_directive_groups = true

# --- this. 修飾子 ------------------------------------------------------------
# this. は不要なら省略する
dotnet_style_qualification_for_field = false:warning
dotnet_style_qualification_for_property = false:warning
dotnet_style_qualification_for_method = false:warning
dotnet_style_qualification_for_event = false:warning

# --- 命名規則：プライベートフィールドは _camelCase ---------------------------
dotnet_naming_rule.private_fields.symbols = private_fields
dotnet_naming_rule.private_fields.style = underscore_camel
dotnet_naming_rule.private_fields.severity = warning

dotnet_naming_symbols.private_fields.applicable_kinds = field
dotnet_naming_symbols.private_fields.applicable_accessibilities = private

dotnet_naming_style.underscore_camel.capitalization = camel_case
dotnet_naming_style.underscore_camel.required_prefix = _

# -----------------------------------------------------------------------------
# JSON / YAML（appsettings.json 等）
# -----------------------------------------------------------------------------
[*.{json,yaml,yml}]
indent_size = 2
EOF

# -----------------------------------------------------------------------------
# frontend/.editorconfig
# -----------------------------------------------------------------------------
echo "作成: frontend/.editorconfig"
cat > frontend/.editorconfig << 'EOF'
# =============================================================================
# frontend/.editorconfig
# React / TypeScript 向け設定
# 細かいフォーマットは Prettier に委譲するため、ここでは最小限の設定のみ
# root = true は書かない → ルートの .editorconfig を継承する
# =============================================================================

# -----------------------------------------------------------------------------
# JS / TS / JSX / TSX
# Prettier の tabWidth と必ず合わせること
# -----------------------------------------------------------------------------
[*.{js,jsx,ts,tsx}]
indent_size = 2

# -----------------------------------------------------------------------------
# スタイル・設定ファイル
# -----------------------------------------------------------------------------
[*.{css,scss,json,yaml,yml,html}]
indent_size = 2
EOF

# -----------------------------------------------------------------------------
# frontend/.prettierrc.js
# -----------------------------------------------------------------------------
echo "作成: frontend/.prettierrc.js"
cat > frontend/.prettierrc.js << 'EOF'
// =============================================================================
// .prettierrc.js
// Vite プロジェクト（package.json に "type": "module"）前提で export default を使用
// CommonJS の場合は export default → module.exports = に変更すること
// =============================================================================

export default {
  // ---------------------------------------------------------------------------
  // 基本フォーマット
  // ---------------------------------------------------------------------------

  // 1行の最大文字数（80は窮屈、120は広すぎる → 100が妥当）
  printWidth: 100,

  // インデント幅（editorconfig の indent_size と合わせること）
  tabWidth: 2,

  // タブ文字ではなくスペースを使用
  useTabs: false,

  // 文末にセミコロンを付ける
  semi: true,

  // JS/TS の文字列はシングルクォート（JSX 属性は別途指定）
  singleQuote: true,

  // JSX の属性値はダブルクォート（HTML の慣習に合わせる）
  jsxSingleQuote: false,

  // 末尾カンマを付ける（Git diff をきれいに保つ・追加時の変更行を最小化）
  trailingComma: 'all',

  // オブジェクトの波括弧内にスペースを入れる: { foo: bar }
  bracketSpacing: true,

  // JSX の閉じ > を次の行に置く（可読性向上）
  bracketSameLine: false,

  // アロー関数の引数は常に括弧で囲む（引数追加時の diff を最小化）
  arrowParens: 'always',

  // ---------------------------------------------------------------------------
  // プラグイン
  // @trivago/prettier-plugin-sort-imports : import 順序の自動整列
  // Tailwind CSS を追加する場合は prettier-plugin-tailwindcss を末尾に追加
  // ---------------------------------------------------------------------------
  plugins: [
    '@trivago/prettier-plugin-sort-imports',
  ],

  // ---------------------------------------------------------------------------
  // import 順序設定（@trivago/prettier-plugin-sort-imports）
  // import のグループ順序を正規表現で定義（上から順に優先度が高い）
  // ---------------------------------------------------------------------------
  importOrder: [
    // 1. React 本体（常に先頭）
    '^react$',
    // 2. React 関連（react-dom, react-router 等）
    '^react-',
    // 3. サードパーティ（node_modules 配下のすべて）
    '<THIRD_PARTY_MODULES>',
    // 4. 内部エイリアス（@/ = src/ への絶対パス）
    '^@/',
    // 5. 相対パス：上位ディレクトリ（../）
    '^\\.\\.',
    // 6. 相対パス：同階層（./）
    '^\\./',
    // 7. CSS / スタイルファイル（常に末尾）
    '^.+\\.css$',
  ],

  // グループ間に空行を挿入する
  importOrderSeparation: true,

  // 同一グループ内の named import をアルファベット順にソートする
  // 例: import { useState, useEffect } → import { useEffect, useState }
  importOrderSortSpecifiers: true,
}
EOF

# -----------------------------------------------------------------------------
# frontend/.prettierignore
# -----------------------------------------------------------------------------
echo "作成: frontend/.prettierignore"
cat > frontend/.prettierignore << 'EOF'
# =============================================================================
# .prettierignore
# Prettier のフォーマット対象から除外するファイル・ディレクトリ
# =============================================================================

# ビルド成果物
dist/
build/

# 依存パッケージ（フォーマット不要・時間の無駄）
node_modules/

# 圧縮済みファイル
*.min.js
*.min.css

# 静的ファイル（外部から取得したものが多いため除外）
public/

# 自動生成ファイル
*.d.ts
EOF

# -----------------------------------------------------------------------------
# 完了メッセージ
# -----------------------------------------------------------------------------
echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "生成されたファイル:"
echo "  .editorconfig"
echo "  .gitattributes"
echo "  .vscode/settings.json"
echo "  backend/.editorconfig"
echo "  frontend/.editorconfig"
echo "  frontend/.prettierrc.js"
echo "  frontend/.prettierignore"
echo ""
echo "次のステップ:"
echo "  1. VS Code 拡張機能をインストール"
echo "     code --install-extension EditorConfig.EditorConfig"
echo "     code --install-extension esbenp.prettier-vscode"
echo ""
echo "  2. frontend の依存パッケージをインストール"
echo "     cd frontend"
echo "     pnpm add -D prettier @trivago/prettier-plugin-sort-imports"
