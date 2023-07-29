{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    { self
    , nixpkgs
    , ...
    } @ inputs:
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
          program = builtins.toString (pkgs.writeScript "" ''
            nixos-rebuild build
            ${pkgs.nvd}/bin/nvd diff /run/current-system ./result
          '');
        };
      };

      checks.${system} =
        builtins.mapAttrs (k: v: v.config.system.build.toplevel) self.nixosConfigurations;

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
      };
    };
}
