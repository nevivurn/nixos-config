{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager-darwin.url = "github:nix-community/home-manager";
    home-manager-darwin.inputs.nixpkgs.follows = "nix-darwin/nixpkgs";
  };

  outputs =
    { self, flake-utils, nixpkgs, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      lib = nixpkgs.lib;
    in

    flake-utils.lib.eachSystem systems
      (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        formatter = pkgs.nixpkgs-fmt;

        # Only custom packages, included self.overlays.default.
        # Mainly for nix-update, so it can automatically update my packages.
        packages = import ./pkgs pkgs;

        apps = {
          nvd-diff = flake-utils.lib.mkApp {
            drv = pkgs.writeScriptBin "nvd-diff" ''
              nixos-rebuild build
              ${lib.getExe pkgs.nvd} diff /run/current-system ./result
            '';
          };

          nix-update = flake-utils.lib.mkApp {
            drv =
              let
                isUpdatable = p:
                  p?version &&
                  lib.hasPrefix self.outPath (builtins.unsafeGetAttrPos "src" p).file;
                upPkgs = lib.flatten
                  (builtins.map
                    (system: builtins.map
                      (name: { inherit system name; })
                      (builtins.attrNames (lib.filterAttrs (_: isUpdatable) self.packages.${system})))
                    systems);
              in
              pkgs.writeScriptBin "nix-update"
                (lib.concatMapStringsSep "\n"
                  (ps: "${lib.getExe pkgs.nix-update} -F --commit --system ${ps.system} ${ps.name}")
                  upPkgs);
          };
        };
      }) //
    {
      # Overlay including custom and overriden packages
      overlays.default = import ./pkgs/overlay.nix;

      # Ensure systems evaluate correctly
      checks = lib.genAttrs systems (system:
        lib.mapAttrs (_: c: c.config.system.build.toplevel) (lib.filterAttrs (_: c: c.pkgs.system == system) self.nixosConfigurations) //
        lib.mapAttrs (_: c: c.system) (lib.filterAttrs (_: c: c.pkgs.system == system) self.darwinConfigurations)
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
          specialArgs = { inherit inputs; };
          modules = [ ./systems/taiyi ];
        };

        tianyi = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./systems/tianyi ];
        };

        athebyne = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./systems/athebyne ];
        };

        funi = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./systems/funi ];
        };
      };
      darwinConfigurations = {
        dziban = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs.inputs = inputs // {
            nixpkgs = inputs.nixpkgs-unstable;
            home-manager = inputs.home-manager-darwin;
          };
          modules = [ ./systems/dziban ];
        };
      };
    };
}
