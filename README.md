# MyBabyBoy



## ABOUT

My son simulator to study Functional Domain Modeling and Haskell.

---

## HOW TO USE

### Initial Set Up

```shell
nix develop
# direnv を使う場合
direnv allow
```

### run locally


```shell
cabal run myapp -- -n Taro
```

```shell
runghc -isrc -iapp app/Main.hs -n Taro
```

---

## For Developer

### test

```shell
runghc -isrc test/Spec.hs
```

### formatter

- treefmt
  - ormolu
  - nixfmt
  - mdformat
  - ghalint
  - pinact

> [!NOTE]
> pinactはGitHub APIを使うため、ネットワークの無い`nix flake check`ではpinactを除外している。

```shell
nix fmt
# 整形漏れのチェック(CI でも実行)
nix flake check
```

### ライブラリの追加

- `myapp.cabal` の `build-depends` に足す。
  - `direnv`不使用の場合には再度`nix develop`する
  - `flake.nix`のdevShellは`hpkgs.shellFor`で`.cabal` から依存を読む
- パッケージはnixpkgs経由で取得し、Hackageからは取得しない。
  - `cabal.project`にもHackageを参照させないように設定済み
- .ghciでデフォルトでimportするライブラリは`/sync-ghci`SKILLSで行う。
- 開発ツール(HLS、tricorderなど)は`.cabal`に書かず、`flake.nix`のdevShellの`nativeBuildInputs`に足す。
- 方針の詳細は[ADR 0001](docs/adr/0001-dependency-management-with-nix.md)を参照。

### tricorder

ビルド状態・診断・テスト結果をデーモンで常時更新するツール。devShellに含まれている。

```shell
# TUIで表示する
tricorder ui
# 現在のビルド状態を表示する
tricorder status
```

### GHC のバージョンを上げる

`flake.nix` の `hpkgs` / `packages.static` と `treefmt.nix` の ormolu の `ghc9122` を揃えて変更する。
