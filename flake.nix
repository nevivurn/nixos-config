{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , impermanence
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      homeConfigurations = {
        shell = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
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
            nixos-hardware = nixos-hardware.nixosModules;
          };
          modules = [
            ./system/taiyi
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
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
