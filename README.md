## Repos / Responsibilities
この構成は「SSOT（remote）+ 端末ごとのglue（local wrapper）」を前提にしています。
- `roccho-dev/flakes`
  - 単一責務のflake（tool bundle / dev tooling / editor tooling 等）を積み上げる場所
  - 「どこでも使える部品」を提供する（= 再利用しやすい小さな成果物）
- `roccho-dev/home`
  - OS層（NixOS）と user層（Home Manager）の “昇格済み” 基盤（foundation）
  - 「安定して常用する設定」を集約し、各端末で再利用できる形で提供する
  - 端末側はこのrepoを *編集しない*（SSOT）
- 各端末（per-machine）
  - `roccho-dev/home` を input として参照し、`extendModules` / overlays で “glue” を足す
  - 端末固有の差分（EDITOR、追加パッケージ、微調整）をここに閉じ込める
 Mental Model (SSOT + Glue)
- SSOT は常に remote の `roccho-dev/home`
- 端末は **local wrapper flake** を1つ用意して、remoteを “wrap” する
- OSもuserも「moduleを合成して適用」という同一モデルで扱う
- 適用コマンドはOSとuserで別（`nixos-rebuild` と `home-manager`）にして世代管理/rollbackを任せる
 Entrypoints (Remote direct)
 OS (NixOS)
- `sudo nixos-rebuild switch --flake github:roccho-dev/home?dir=.os#y-wsl`
- `sudo nixos-rebuild switch --flake github:roccho-dev/home?dir=.os#nixos-vm`
 User (Home Manager)
- `home-manager switch --flake github:roccho-dev/home?dir=.config/nix#nixos`
home-managerコマンドが無い場合（ブートストラップ）:
- `nix run nixpkgs#home-manager -- switch --flake github:roccho-dev/home?dir=.config/nix#nixos`

## Recommended: Per-machine wrapper (~/.nix)
端末固有の差分は `~/.nix` に閉じ込める（このrepoはSSOTとして参照のみ）。
例:
```tree
~/.nix/
  flake.nix
  flake.lock
  modules/
    nixos/
      editor-hx.nix
    home/
      editor-hx.nix
      tools.nix
```

`flake.nix` のイメージ:
- inputs: `os = github:roccho-dev/home?dir=.os`
- inputs: `home = github:roccho-dev/home?dir=.config/nix`
- 必要なら inputs: `tooling = github:roccho-dev/flakes`（tool bundle再利用）
出力:
- `nixosConfigurations = mapAttrs (_: cfg: cfg.extendModules { modules = [ ... ]; }) os.nixosConfigurations;`
- `homeConfigurations  = mapAttrs (_: cfg: cfg.extendModules { modules = [ ... ]; }) home.homeConfigurations;`
適用:
- OS: `sudo nixos-rebuild switch --flake ~/.nix#y-wsl`
- User: `home-manager switch --flake ~/.nix#nixos`
例（EDITORの上書き）:
- OS側: `environment.variables.EDITOR = "hx";`
- User側: `home.sessionVariables.EDITOR = "hx";`
## Update policy (recommended)
- per-machine wrapper の `flake.lock` で基盤（remote）のrevを固定する
- 更新は端末側で意図的に行う（例: `nix flake update`）
  - これにより “勝手に変わる” を避けつつ、必要時に追従できる