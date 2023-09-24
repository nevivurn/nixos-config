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
    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
        packages = import ./pkgs { inherit pkgs; };

        apps = {
          nvd-diff = flake-utils.lib.mkApp {
            drv = pkgs.writeScriptBin "nvd-diff" ''
              nixos-rebuild build
              ${pkgs.nvd}/bin/nvd diff /run/current-system ./result
            '';
          };

          nix-update = flake-utils.lib.mkApp {
            drv =
              let
                upPkgs = builtins.attrNames (lib.filterAttrs
                  (_: p:
                    p?version &&
                    lib.hasPrefix self.outPath (builtins.unsafeGetAttrPos "src" p).file)
                  self.packages.${system});
              in
              pkgs.writeScriptBin "nix-update" ''
                for pkg in ${builtins.concatStringsSep " " upPkgs}; do
                  ${pkgs.nix-update}/bin/nix-update -F --commit ''${pkg}
                done
              '';
          };
        };
      }) //
    {
      # Overlay including custom and overriden packages
      overlays.default = import ./pkgs/overlay.nix;

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
            home-manager = inputs.home-manager-unstable;
          };
          modules = [ ./systems/dziban ];
        };
      };
    };
}
