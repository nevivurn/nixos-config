{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , impermanence
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      homeConfigurations = {
        shell = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          specialArgs = {
            inherit pkgsUnstable;
          };
          modules = [
            ./home/profiles/shell
            {
              home.username = "nevivurn";
              home.homeDirectory = "/home/nevivurn";
            }
          ];
        };
      };

      nixosConfigurations = {
        taiyi = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgsUnstable;
            nixos-hardware = nixos-hardware.nixosModules;
          };
          modules = [
            ./system/taiyi
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit pkgsUnstable;
              };
              home-manager.users.nevivurn.imports = [
                ./home/profiles/sway
                impermanence.nixosModules.home-manager.impermanence
              ];
            }
          ];
        };
      };
    };
}
