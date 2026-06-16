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
#   frontend/tsconfig.json
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

# =============================================================================
# 命名規則
# =============================================================================

# --- クラス・構造体・enum・デリゲート → PascalCase --------------------------
dotnet_naming_rule.types.symbols = types
dotnet_naming_rule.types.style = pascal_case
dotnet_naming_rule.types.severity = error

dotnet_naming_symbols.types.applicable_kinds = class,struct,enum,delegate

dotnet_naming_style.pascal_case.capitalization = pascal_case

# --- インターフェース → IPascalCase ------------------------------------------
dotnet_naming_rule.interfaces.symbols = interfaces
dotnet_naming_rule.interfaces.style = i_prefix
dotnet_naming_rule.interfaces.severity = error

dotnet_naming_symbols.interfaces.applicable_kinds = interface

dotnet_naming_style.i_prefix.capitalization = pascal_case
dotnet_naming_style.i_prefix.required_prefix = I

# --- 型パラメータ → TPascalCase ----------------------------------------------
dotnet_naming_rule.type_parameters.symbols = type_parameters
dotnet_naming_rule.type_parameters.style = t_prefix
dotnet_naming_rule.type_parameters.severity = error

dotnet_naming_symbols.type_parameters.applicable_kinds = type_parameter

dotnet_naming_style.t_prefix.capitalization = pascal_case
dotnet_naming_style.t_prefix.required_prefix = T

# --- public メソッド・プロパティ・イベント → PascalCase ----------------------
dotnet_naming_rule.public_members.symbols = public_members
dotnet_naming_rule.public_members.style = pascal_case
dotnet_naming_rule.public_members.severity = error

dotnet_naming_symbols.public_members.applicable_kinds = method,property,event
dotnet_naming_symbols.public_members.applicable_accessibilities = public,internal,protected,protected_internal

# --- const → PascalCase（ALL_CAPS は C# 標準ではない）-----------------------
dotnet_naming_rule.constants.symbols = constants
dotnet_naming_rule.constants.style = pascal_case
dotnet_naming_rule.constants.severity = error

dotnet_naming_symbols.constants.applicable_kinds = field
dotnet_naming_symbols.constants.required_modifiers = const

# --- private フィールド → _camelCase -----------------------------------------
dotnet_naming_rule.private_fields.symbols = private_fields
dotnet_naming_rule.private_fields.style = underscore_camel
dotnet_naming_rule.private_fields.severity = error

dotnet_naming_symbols.private_fields.applicable_kinds = field
dotnet_naming_symbols.private_fields.applicable_accessibilities = private

dotnet_naming_style.underscore_camel.capitalization = camel_case
dotnet_naming_style.underscore_camel.required_prefix = _

# --- static readonly フィールド（public） → PascalCase -----------------------
dotnet_naming_rule.static_readonly.symbols = static_readonly
dotnet_naming_rule.static_readonly.style = pascal_case
dotnet_naming_rule.static_readonly.severity = error

dotnet_naming_symbols.static_readonly.applicable_kinds = field
dotnet_naming_symbols.static_readonly.applicable_accessibilities = public,internal
dotnet_naming_symbols.static_readonly.required_modifiers = static,readonly

# --- パラメータ・ローカル変数 → camelCase ------------------------------------
dotnet_naming_rule.locals_and_params.symbols = locals_and_params
dotnet_naming_rule.locals_and_params.style = camel_case
dotnet_naming_rule.locals_and_params.severity = warning

dotnet_naming_symbols.locals_and_params.applicable_kinds = parameter,local

dotnet_naming_style.camel_case.capitalization = camel_case

# --- 非同期メソッド → Async サフィックス（EditorConfig では suffix 未対応）
# ※ Async サフィックスの強制は StyleCop.Analyzers (SA1302) または
#    SonarAnalyzer を使用すること

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
# frontend/tsconfig.json
# -----------------------------------------------------------------------------
echo "作成: frontend/tsconfig.json"
cat > frontend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    // =========================================================================
    // ターゲット・モジュール
    // =========================================================================

    // モダンブラウザ向け（Vite がトランスパイルするため最新で問題なし）
    "target": "ES2022",

    // ESModules（Vite 前提）
    "module": "ESNext",

    // モジュール解決は bundler モード（Vite / webpack 向け）
    "moduleResolution": "bundler",

    // =========================================================================
    // 厳格モード（全て有効化推奨）
    // =========================================================================

    // strict: true は以下をまとめて有効化する
    //   - strictNullChecks   : null/undefined の型安全
    //   - noImplicitAny      : 暗黙的 any の禁止
    //   - strictFunctionTypes: 関数型の厳格チェック
    //   - strictBindCallApply: bind/call/apply の型チェック
    //   - strictPropertyInitialization: クラスプロパティの初期化チェック
    //   - noImplicitThis     : this の型チェック
    //   - alwaysStrict       : 全ファイルに "use strict" を付与
    "strict": true,

    // 未使用ローカル変数をエラーにする（コードの整理を強制）
    "noUnusedLocals": true,

    // 未使用パラメータをエラーにする
    "noUnusedParameters": true,

    // switch の fall-through をエラーにする（break 忘れ防止）
    "noFallthroughCasesInSwitch": true,

    // 型のみの import は type import を強制（バンドルサイズ最適化）
    "verbatimModuleSyntax": true,

    // =========================================================================
    // パス・エイリアス
    // =========================================================================

    // @/ で src/ を参照できるようにする（vite.config.ts の resolve.alias と合わせること）
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },

    // =========================================================================
    // JSX
    // =========================================================================

    // React 17+ の新しい JSX 変換（import React が不要になる）
    "jsx": "react-jsx",

    // =========================================================================
    // ライブラリ
    // =========================================================================

    // DOM API と ESNext の型定義を使用
    "lib": ["ES2022", "DOM", "DOM.Iterable"],

    // =========================================================================
    // その他
    // =========================================================================

    // デフォルトエクスポートのない CommonJS モジュールを interop する
    "esModuleInterop": true,

    // ファイル名の大文字小文字を厳密にチェック（Linux/Windows の差異を防ぐ）
    "forceConsistentCasingInFileNames": true,

    // 型チェックのみ実行（トランスパイルは Vite に任せる）
    "noEmit": true,

    // インクリメンタルビルドのキャッシュ
    "incremental": true,
    "tsBuildInfoFile": "node_modules/.cache/tsbuildinfo"
  },

  "include": [
    "src/**/*",
    "vite.config.ts"
  ],

  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF

# -----------------------------------------------------------------------------
# frontend/eslint.config.js
# -----------------------------------------------------------------------------
echo "作成: frontend/eslint.config.js"
cat > frontend/eslint.config.js << 'EOF'
// =============================================================================
// eslint.config.js
// TypeScript + React 向け ESLint Flat Config
// 命名規則は @typescript-eslint/naming-convention で一元管理する
// =============================================================================

import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';

export default tseslint.config(
  // ---------------------------------------------------------------------------
  // 対象外ディレクトリ
  // ---------------------------------------------------------------------------
  { ignores: ['dist', 'node_modules'] },

  // ---------------------------------------------------------------------------
  // JS 推奨ルール
  // ---------------------------------------------------------------------------
  js.configs.recommended,

  // ---------------------------------------------------------------------------
  // TypeScript 推奨ルール（型チェックあり）
  // ---------------------------------------------------------------------------
  ...tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },

  // ---------------------------------------------------------------------------
  // React 向けルール
  // ---------------------------------------------------------------------------
  {
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      // Fast Refresh の対象外コンポーネントを警告（エラーにしない）
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
    },
  },

  // ---------------------------------------------------------------------------
  // 命名規則 + プロジェクト共通ルール
  // ---------------------------------------------------------------------------
  {
    rules: {
      // -----------------------------------------------------------------------
      // 命名規則（@typescript-eslint/naming-convention）
      // -----------------------------------------------------------------------
      '@typescript-eslint/naming-convention': [
        'error',

        // デフォルト: camelCase（最も広いセレクタ → 他のルールで上書き可能）
        {
          selector: 'default',
          format: ['camelCase'],
          leadingUnderscore: 'allow', // 未使用パラメータの _ プレフィックスを許容
        },

        // 変数: camelCase または UPPER_CASE（定数）
        // React コンポーネントは PascalCase も許容
        {
          selector: 'variable',
          format: ['camelCase', 'PascalCase', 'UPPER_CASE'],
        },

        // 関数: camelCase（通常関数）または PascalCase（React コンポーネント）
        {
          selector: 'function',
          format: ['camelCase', 'PascalCase'],
        },

        // boolean 変数: is / has / should プレフィックスを強制
        {
          selector: 'variable',
          types: ['boolean'],
          format: ['PascalCase'],
          prefix: ['is', 'has', 'should', 'can', 'will'],
        },

        // クラス・型エイリアス・enum → PascalCase
        {
          selector: 'typeLike',
          format: ['PascalCase'],
        },

        // インターフェース → PascalCase（I プレフィックスは不要: TS 標準）
        {
          selector: 'interface',
          format: ['PascalCase'],
          // I プレフィックスを付けたい場合は以下のコメントを外す
          // prefix: ['I'],
        },

        // 型パラメータ → T プレフィックス必須（例: TItem, TResponse）
        {
          selector: 'typeParameter',
          format: ['PascalCase'],
          prefix: ['T'],
        },

        // enum メンバ → PascalCase
        {
          selector: 'enumMember',
          format: ['PascalCase'],
        },

        // オブジェクトのプロパティ: camelCase（API レスポンスは除外したい場合は requires-type-checking で対応）
        {
          selector: 'objectLiteralProperty',
          format: ['camelCase', 'PascalCase', 'UPPER_CASE'],
          // snake_case の API レスポンスを扱う場合はコメントを外す
          // filter: { regex: '^[a-z_]+$', match: false },
        },
      ],

      // -----------------------------------------------------------------------
      // TypeScript 一般ルール
      // -----------------------------------------------------------------------

      // any を明示的に使う場合は警告（完全禁止より現実的）
      '@typescript-eslint/no-explicit-any': 'warn',

      // 未使用変数はエラー（_ プレフィックスは除外）
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],

      // 浮動 Promise（await なし・then なし）を禁止
      '@typescript-eslint/no-floating-promises': 'error',

      // async 関数で常に Promise を返すことを強制（不要な async を防ぐ）
      '@typescript-eslint/require-await': 'error',
    },
  },
);
EOF

# -----------------------------------------------------------------------------
# SETUP.md
# -----------------------------------------------------------------------------
echo "作成: SETUP.md"
cat > SETUP.md << 'EOF'
# セットアップ手順

このファイルは `setup-editorconfig.sh` を実行後に必要な手順をまとめたものです。

---

## 1. VS Code 拡張機能

```bash
code --install-extension EditorConfig.EditorConfig
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension ms-dotnettools.csharp
```

| 拡張機能 | 用途 |
|----------|------|
| EditorConfig.EditorConfig | `.editorconfig` を読んでエディタ設定を自動適用 |
| esbenp.prettier-vscode | frontend の保存時フォーマット（Prettier） |
| dbaeumer.vscode-eslint | ESLint エラー・警告をエディタ上に表示 |
| ms-dotnettools.csharp | C# の保存時フォーマット・IntelliSense |

---

## 2. frontend パッケージ

```bash
cd frontend
pnpm add -D \
  prettier \
  @trivago/prettier-plugin-sort-imports \
  eslint \
  typescript-eslint \
  @eslint/js \
  eslint-plugin-react-hooks \
  eslint-plugin-react-refresh
```

| パッケージ | 用途 |
|------------|------|
| prettier | コードフォーマッター本体 |
| @trivago/prettier-plugin-sort-imports | import 順序の自動整列 |
| eslint | 静的解析ツール本体 |
| typescript-eslint | TypeScript 向け ESLint ルールセット |
| @eslint/js | ESLint 公式 JS 推奨ルール |
| eslint-plugin-react-hooks | React Hooks のルール強制 |
| eslint-plugin-react-refresh | Vite Fast Refresh の警告 |

---

## 3. backend パッケージ（NuGet）

`.csproj` に追加して `dotnet restore` を実行します。

```xml
<ItemGroup>
  <!-- 静的解析 -->
  <PackageReference Include="SonarAnalyzer.CSharp" Version="10.9.0.115408">
    <PrivateAssets>all</PrivateAssets>
  </PackageReference>
  <PackageReference Include="Meziantou.Analyzer" Version="2.0.185">
    <PrivateAssets>all</PrivateAssets>
  </PackageReference>

  <!-- EF Core -->
  <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="9.0.0" />
  <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="9.0.0">
    <PrivateAssets>all</PrivateAssets>
  </PackageReference>
</ItemGroup>
```

| パッケージ | 用途 |
|------------|------|
| SonarAnalyzer.CSharp | バグ・セキュリティ・コードスメル検出（600以上のルール） |
| Meziantou.Analyzer | コード品質・パフォーマンス系ルール |
| Microsoft.EntityFrameworkCore.SqlServer | EF Core SQL Server プロバイダ |
| Microsoft.EntityFrameworkCore.Tools | マイグレーションコマンド（dotnet ef） |

---

## 4. Git Hook

チーム全員が以下を実行します（初回のみ）。

```bash
git config core.hooksPath .githooks
```

`.githooks/pre-commit` の内容：

```sh
#!/bin/sh
# frontend: ESLint + Prettier チェック
cd frontend && pnpm eslint . && pnpm prettier --check . && cd ..

# backend: フォーマット + 静的解析
dotnet format --verify-no-changes
dotnet build --no-incremental -warnaserror
```

---

## 5. vite.config.ts への追記

`@/` エイリアスを有効にするため `vite.config.ts` に追加します。

```ts
import path from 'path';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
});
```

---

## 6. 命名規則まとめ

### TypeScript / React（ESLint で強制）

| 対象 | 規則 | 例 |
|------|------|----|
| 変数・関数 | camelCase | `userName`, `fetchData` |
| React コンポーネント | PascalCase | `UserCard`, `LoginForm` |
| 定数 | UPPER_CASE | `MAX_RETRY_COUNT` |
| boolean 変数 | is/has/should/can/will プレフィックス | `isLoading`, `hasError` |
| 型・インターフェース・クラス | PascalCase | `UserResponse`, `ApiClient` |
| 型パラメータ | T プレフィックス | `TItem`, `TResponse` |
| enum メンバ | PascalCase | `Status.Active` |

### C#（EditorConfig + SonarAnalyzer で強制）

| 対象 | 規則 | 例 |
|------|------|----|
| クラス・構造体・enum | PascalCase | `UserService`, `OrderStatus` |
| インターフェース | I プレフィックス | `IUserRepository` |
| 型パラメータ | T プレフィックス | `TEntity`, `TResult` |
| public メソッド・プロパティ | PascalCase | `GetById`, `UserName` |
| const | PascalCase | `MaxRetryCount` |
| private フィールド | _ プレフィックス + camelCase | `_userRepository` |
| パラメータ・ローカル変数 | camelCase | `userId`, `orderList` |
| 非同期メソッド | Async サフィックス ※StyleCop 必要 | `GetByIdAsync` |
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
echo "  frontend/tsconfig.json"
echo "  frontend/eslint.config.js"
echo "  SETUP.md"
echo ""
echo "詳細な手順は SETUP.md を参照してください。"
