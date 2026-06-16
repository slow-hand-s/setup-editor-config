# SonarAnalyzer.CSharp 導入ガイド

検出パターンと Git Hook 導入のメリット・デメリット

-----

## 1. SonarAnalyzer.CSharp とは

SonarSource が提供する Roslyn ベースの静的解析ツール。NuGet パッケージとして追加するだけで `dotnet build` 時に自動実行される。600以上のルールでバグ・セキュリティ脆弱性・コードスメルを検出。

-----

## 2. 検出パターン

### 2-1. バグ検出

コンパイルは通過するが実行時に問題となるコードパターンを検出。

|ルールID|検出内容                  |例                                    |
|-----|----------------------|-------------------------------------|
|S2589|条件が常に true/false      |`if (list.Count >= 0)` → Count は常に0以上|
|S1764|同一オペランドの比較            |`if (a == a)` → 常にtrue               |
|S2234|引数の順序ミス               |メソッド定義と異なる順序で引数を渡している                |
|S3655|null チェックなしの Value 参照 |`Nullable<T>.Value` をnullチェックなしで使用   |
|S2259|NullPointerDereference|null の可能性があるオブジェクトのメンバ参照             |

### 2-2. セキュリティ脆弱性

OWASP Top 10 をカバーするセキュリティルールが含まれる。

|ルールID|検出内容          |リスク                       |
|-----|--------------|--------------------------|
|S2068|ハードコードされた認証情報 |パスワード・APIキーのソースコード埋め込み    |
|S4790|弱いハッシュアルゴリズム使用|MD5・SHA1 → SHA256以上を推奨    |
|S2245|安全でない乱数生成     |`Random` クラス → セキュリティ用途に不適|
|S5042|Zip Slip 脆弱性  |ZipEntry のパストラバーサル        |
|S4507|デバッグ機能の本番露出   |スタックトレースなどの詳細エラー出力        |

### 2-3. async/await パターン

C# 特有の非同期処理の誤用を検出。

|ルールID|検出内容              |推奨                             |
|-----|------------------|-------------------------------|
|S3168|async void の誤用    |`async void` → `async Task` に変更|
|S4462|Task を await せずに破棄|fire-and-forget の意図しない使用       |
|S6966|同期 API の誤用        |非同期コンテキストで同期 API を呼び出し         |

### 2-4. コードスメル

保守性・可読性を低下させるパターンを検出。

|ルールID|検出内容            |備考               |
|-----|----------------|-----------------|
|S1172|未使用のメソッドパラメータ   |インターフェース実装の場合は除外可|
|S107 |パラメータが多すぎるメソッド  |デフォルト7個以上で警告     |
|S3776|認知的複雑度が高い       |デフォルト閾値15を超えると警告 |
|S1144|未使用の private メンバ|デッドコードの検出        |
|S2326|未使用の型パラメータ      |ジェネリック型定義の誤り     |

-----

## 3. Git Hook への組み込み

### 3-1. 仕組み

pre-commit フックで `dotnet build` を実行し、SonarAnalyzer が検出したエラーがある場合はコミットを中止する。`TreatWarningsAsErrors` を有効にしているため、警告レベルの検出もコミットを阻止する。

```sh
# .githooks/pre-commit
#!/bin/sh
dotnet format --verify-no-changes && dotnet build --no-incremental -warnaserror
```

チーム共有するには `.githooks/` にコミットして以下を実行してもらう。

```sh
git config core.hooksPath .githooks
```

### 3-2. メリット

|項目          |内容                                |
|------------|----------------------------------|
|早期検出        |PR・CIより前に開発者個人の環境で問題を検出できる        |
|CI 負荷軽減     |明らかなエラーが CI に到達しないためビルド失敗の回数が減る   |
|チーム品質の底上げ   |全員が同一ルールで強制されるため個人差が縮まる           |
|追加インフラ不要    |SonarQube サーバー等を立てずに静的解析を導入できる    |
|フォーマット同時チェック|`dotnet format` と組み合わせて書式違反も同時に弾ける|

### 3-3. デメリット・注意点

|項目        |内容                                   |対策                                   |
|----------|-------------------------------------|-------------------------------------|
|コミット速度の低下 |`dotnet build` が毎回走るため数秒〜数十秒かかる      |`--no-incremental` をやめてインクリメンタルビルドにする|
|初回導入の痛み   |既存コードに大量の警告が出て作業が止まる可能性              |`NoWarn` で段階的に有効化する                  |
|Hook のスキップ|`git commit --no-verify` で回避できる      |CI 側にも同じチェックを入れて二重防御する               |
|環境依存      |.NET SDK バージョンが揃っていないと結果が変わる         |`global.json` で SDK バージョンを固定する       |
|改行コード問題   |Windows 環境でシェルスクリプトの CRLF 問題が起きることがある|`.gitattributes` で `eol=lf` を指定する    |

-----

## 4. 推奨セットアップ

### 4-1. .csproj

```xml
<PropertyGroup>
  <Nullable>enable</Nullable>
  <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  <AnalysisLevel>latest</AnalysisLevel>
  <AnalysisMode>All</AnalysisMode>
  <NoWarn>CA1062;CA2007</NoWarn>
</PropertyGroup>

<ItemGroup>
  <PackageReference Include="SonarAnalyzer.CSharp" Version="10.9.0.115408">
    <PrivateAssets>all</PrivateAssets>
  </PackageReference>
</ItemGroup>
```

### 4-2. 段階的なルール有効化

1. まず `NoWarn` を広めに設定してコミットを通す
1. スプリント単位で `NoWarn` から 1〜2 ルールずつ削除
1. CI が整ったら `--verify-no-changes` をパイプラインに追加

-----

## 5. まとめ

|観点           |評価|補足                               |
|-------------|--|---------------------------------|
|検出精度         |◎ |600以上のルール。Nullable 有効化と組み合わせると高水準|
|導入コスト        |○ |NuGet 追加と .csproj 設定のみ。サーバー不要    |
|Git Hook との相性|○ |`dotnet build` に乗るため追加スクリプトが少ない  |
|チーム運用        |△ |初期の `NoWarn` 調整とスキップ対策が必要        |
|CI との二重防御    |推奨|Hook はスキップ可能なため CI にも同様のチェックを追加  |