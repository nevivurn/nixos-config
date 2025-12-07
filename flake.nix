{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }@inputs:
    let
      systems = [ "x86_64-linux" ];
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
        formatter = treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };

        # Only custom packages, included in self.overlays.default.
        # Mainly for nix-update, so it can automatically update my packages.
        # Everything else just uses the overlay.
        packages = import ./pkgs pkgs;

        apps = {
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
                pkg = pkgs.writeShellApplication {
                  name = "nix-update";
                  text = (
                    ''
                      nix flake update --commit-lock-file
                    ''
                    + (lib.concatMapStringsSep "\n" (
                      ps: "${lib.getExe pkgs.nix-update} -F --commit --system ${ps.system} ${ps.name}"
                    ) upPkgs)
                  );
                };
              in
              lib.getExe pkg;
            meta = {
              description = "Updates Nix flake inputs and packages";
              inherit (pkgs.nix-update.meta) platforms;
            };
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
          configs = lib.mapAttrs (_: c: c.config.system.build.toplevel) (
            lib.filterAttrs (_: c: c.pkgs.system == system) self.nixosConfigurations
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

        giausar = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/giausar ];
        };

        alrakis = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/alrakis ];
        };

        alsafi = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./systems/alsafi ];
        };
      };
    };
}
