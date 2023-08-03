{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";

    nix-update.url = "github:Mic92/nix-update/0.19.2";
    nix-update.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, home-manager, nix-update, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system} = import ./pkgs { inherit pkgs; };
      overlays.default = import ./pkgs/overlay.nix;

      nixosModules = {
        default = import ./nixos/modules;
        graphical = import ./nixos/profiles/graphical;
      };
      homeConfigurations = {
        default = import ./home/modules;
        sway = import ./home/profiles/sway;
        develop = import ./home/profiles/develop;
        shell = import ./home/profiles/shell;
      };

      apps.${system} = {
        nvd-diff = {
          type = "app";
          program = builtins.toString (pkgs.writeScript "nvd-diff" ''
            nixos-rebuild build
            ${pkgs.nvd}/bin/nvd diff /run/current-system ./result
          '');
        };

        nix-update = {
          type = "app";
          program =
            let
              updater = nix-update.packages.${system}.nix-update;
              upPkgs = builtins.attrNames (nixpkgs.lib.filterAttrs (_: p: p?version) self.packages.${system});
            in
            builtins.toString (pkgs.writeScript "nix-update" ''
              for pkg in ${builtins.concatStringsSep " " upPkgs}; do
                ${updater}/bin/nix-update -F --commit ''${pkg}
              done
            '');
        };
      };

      checks.${system} =
        builtins.mapAttrs (_: v: v.config.system.build.toplevel)
          # do not build funi in CI, building the kernel takes too many resources
          (nixpkgs.lib.filterAttrs (k: _: k != "funi") self.nixosConfigurations);

      nixosConfigurations = {
        alrakis = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./systems/alrakis ];
        };

        taiyi = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./systems/taiyi ];
        };

        athebyne = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./systems/athebyne ];
        };

        funi = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs.inputs = {
            inherit (inputs) self nixpkgs nixos-hardware home-manager;
          };
          modules = [ ./systems/funi ];
        };
      };
    };
}
