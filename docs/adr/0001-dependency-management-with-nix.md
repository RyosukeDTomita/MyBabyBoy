# 0001. 依存ライブラリと開発ツールの管理方針

- Status: Accepted
- Date: 2026-10-14

---

## Context

- GHCとライブラリのバージョンを、ローカル・CI・`nix build` の間で一致させたい。
- Hackageとnixpkgsの両方から取得すると、`~/.cabal/store` とnix storeに同じパッケージが二重にでき、依存の解決結果もずれる。
- ビルドに必要なライブラリと、開発時だけ使うツール(HLS、formatter、tricorderなど)の置き場所が決まっていなかった。

---

## Decision

### 1. パッケージの取得元はnixpkgsに一本化し、Hackageは使わない

- `cabal.project` に `active-repositories: :none` を設定する。
- cabalは、`nix develop`(`hpkgs.shellFor`)が用意したGHCのパッケージDBだけで依存を解決する。

### 2. `myapp.cabal` に書くのは、プロジェクトのコードが直接importするライブラリだけにする

- 書くもの: `build-depends`(library / executable / test-suite)
- 書かないもの: 実行ファイルとして使う開発ツール(`build-tool-depends` も使わない)

### 3. 開発ツールは `flake.nix` のdevShellの `nativeBuildInputs` に置く

- nixpkgsにあるツールは、`hpkgs.xxx` / `pkgs.xxx` で追加する。
- nixpkgsに無いツールは、そのツールのflakeをinputに追加する(例: tricorder)。

---

## Consequences

### 良い点

- 環境を再現できる。ローカル・CI・`nix build` で同じバージョンが使われる。
- パッケージの二重管理がなくなる。
- `nix build` や静的バイナリに、開発ツールが混ざらない。

### 悪い点

- プロジェクト内では `cabal install <tool>` が使えない。取得元が無いため失敗する。
- nixpkgsに無いライブラリや古いライブラリは、overlayやflake inputで対応する必要がある。
- 開発ツールのflakeがバイナリキャッシュに対応していないと、初回の `nix develop` に時間がかかる。

---

## 補足: よくある誤解

- 「cabalのインストール先がnixになっている」わけではない。cabalはnixが用意したパッケージを読むだけで、nix storeへは書き込めない。
- 全プロジェクトで使うツールとして入れたい場合は、プロジェクトの外で `cabal install` すれば入れられる。ただし、その場合はNixの管理外になる。
