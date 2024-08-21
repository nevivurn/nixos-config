{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-darwin.url = "github:nix-community/home-manager/release-24.05";
    home-manager-darwin.inputs.nixpkgs.follows = "nix-darwin/nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      inherit (nixpkgs) lib;

      # from flake-utils
      eachSystem =
        f:
        let
          op =
            attrs: system:
            let
              ret = f system;
              op =
                attrs: key:
                attrs
                // {
                  ${key} = (attrs.${key} or { }) // {
                    ${system} = ret.${key};
                  };
                };
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;
    in
    eachSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        # Only custom packages, included in self.overlays.default.
        # Mainly for nix-update, so it can automatically update my packages.
        # Everything else just uses the overlay.
        packages = import ./pkgs pkgs;

        apps = {
          nvd-diff = {
            type = "app";
            program =
              let
                pkg = pkgs.writeScriptBin "nvd-diff" ''
                  nixos-rebuild build
                  ${lib.getExe pkgs.nvd} diff /run/current-system ./result
                '';
              in
              lib.getExe pkg;
          };

          nix-update = {
            type = "app";
            program =
              let
                isUpdatable = p: p ? version && lib.hasPrefix self.outPath (builtins.unsafeGetAttrPos "src" p).file;
                upPkgs = lib.flatten (
                  builtins.map (
                    system:
                    builtins.map (name: { inherit system name; }) (
                      builtins.attrNames (lib.filterAttrs (_: isUpdatable) self.packages.${system})
                    )
                  ) systems
                );
                pkg = pkgs.writeScriptBin "nix-update" (
                  ''
                    nix flake update --commit-lock-file
                  ''
                  + (lib.concatMapStringsSep "\n" (
                    ps: "${lib.getExe pkgs.nix-update} -F --commit --system ${ps.system} ${ps.name}"
                  ) upPkgs)
                );
              in
              lib.getExe pkg;
          };
        };
      }
    )
    // {
      # Overlay including custom and overriden packages
      overlays.default = import ./pkgs/overlay.nix;

      # Ensure systems evaluate correctly
      checks = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configs =
            lib.mapAttrs (_: c: c.config.system.build.toplevel) (
              lib.filterAttrs (_: c: c.pkgs.system == system) self.nixosConfigurations
            )
            // lib.mapAttrs (_: c: c.system) (
              lib.filterAttrs (_: c: c.pkgs.system == system) self.darwinConfigurations
            );
        in
        configs // { allConfigs = pkgs.linkFarmFromDrvs "all-configs" (builtins.attrValues configs); }
      );

      nixosModules = {
        default = import ./nixos/modules;
        graphical = import ./nixos/profiles/graphical;
      };
      homeModules = {
        default = import ./home/modules;
        sway = import ./home/profiles/sway;
        develop = import ./home/profiles/develop;
        shell = import ./home/profiles/shell;
      };

      nixosConfigurations = {
        taiyi = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/taiyi ];
        };

        tianyi = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/tianyi ];
        };

        athebyne = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/athebyne ];
        };

        funi = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/funi ];
        };

        rastaban = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/rastaban ];
        };

        giausar = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/giausar ];
        };

        nvvm = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/nvvm ];
        };

        iso = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/iso ];
        };
      };
      darwinConfigurations = {
        grumium = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs.inputs = inputs // {
            nixpkgs = inputs.nixpkgs-darwin;
            home-manager = inputs.home-manager-darwin;
          };
          modules = [ ./systems/grumium ];
        };
      };
    };
}
