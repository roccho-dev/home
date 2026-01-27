{
  description = "Nix configuration (os + hm unified)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    sync = {
      url = "github:PorcoRosso85/flakes?dir=sync";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      nixos-wsl,
      home-manager,
      sync,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        rent-wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./os/rent-wsl/default.nix
            ./os/common.nix
            ./os/secrets.nix
            sync.nixosModules.default
            sops-nix.nixosModules.sops
            nixos-wsl.nixosModules.wsl
            home-manager.nixosModules.home-manager
            {
              home-manager.users.nixos = import ./hm/home.nix;
            }
            (
              { lib, ... }:
              {
                _module.args.self = lib.mkDefault self;
              }
            )
          ];
        };

        nixos-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./os/nixos-vm/default.nix
            ./os/common.nix
            ./os/secrets.nix
            sync.nixosModules.default
            sops-nix.nixosModules.sops

            # Only for evaluation/CI: keep flake check green without requiring bootloader settings.
            (
              { lib, ... }:
              {
                boot.loader.grub.enable = lib.mkDefault false;
              }
            )
          ];
        };
      };

      homeConfigurations = {
        "nixos@rent-wsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./hm/home.nix ];
        };
      };
    };
}
