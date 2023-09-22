{ lib, config, pkgs, ... }:

# NFSv4 fix for 6.5.3, 6.1.53, & 6.1.54, remove asap
let
  version = config.boot.kernelPackages.kernel.version;
  badVersions = [ "6.5.3" "6.1.53" "6.1.54" ];
in

lib.mkIf (lib.any (v: v == version) badVersions) {
  boot.kernelPatches = [{
    name = "nfs4-patch";
    patch = pkgs.fetchpatch {
      url = "https://patchwork.kernel.org/project/selinux/patch/20230911142358.883728-1-omosnace@redhat.com/raw/";
      hash = "sha256-m947t39xr4VqJBZ2mYTFq9Up/NWlwueH8aXFZRQwA7c=";
    };
  }];
}
