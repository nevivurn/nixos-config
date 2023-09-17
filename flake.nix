{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";

    nix-update.url = "github:Mic92/nix-update/0.19.3";
    nix-update.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, home-manager, nix-update, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      # Overlay including custom and overriden packages
      overlays.default = import ./pkgs/overlay.nix;
      # Only custom packages, included in above overlay.
      # Mainly for nix-update, so it can automatically update my packages.
      packages.${system} = import ./pkgs { inherit pkgs; };

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

      apps.${system} = {
        nvd-diff = {
          type = "app";
          program = (pkgs.writeScript "nvd-diff" ''
            nixos-rebuild build
            ${pkgs.nvd}/bin/nvd diff /run/current-system ./result
          '').outPath;
        };

        nix-update = {
          type = "app";
          program =
            let
              updater = nix-update.packages.${system}.nix-update;
              upPkgs = builtins.attrNames (lib.filterAttrs
                (_: p:
                  p?version &&
                  lib.hasPrefix self.outPath (builtins.unsafeGetAttrPos "src" p).file)
                self.packages.${system});
            in
            (pkgs.writeScript "nix-update" ''
              for pkg in ${builtins.concatStringsSep " " upPkgs}; do
                ${updater}/bin/nix-update -F --commit ''${pkg}
              done
            '').outPath;
        };
      };

      checks.${system} = builtins.mapAttrs (_: v: v.config.system.build.toplevel) self.nixosConfigurations;

      nixosConfigurations = {
        taiyi = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./systems/taiyi ];
        };

        tianyi = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./systems/tianyi ];
        };

        athebyne = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./systems/athebyne ];
        };

        funi = lib.nixosSystem {
          inherit system;
          specialArgs.inputs = {
            inherit (inputs) self nixpkgs nixpkgs-unstable nixos-hardware home-manager;
          };
          modules = [ ./systems/funi ];
        };
      };
    };
}
