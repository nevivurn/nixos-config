{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkMerge [
  {
    networking = {
      nftables.enable = true;
      dhcpcd.enable = false;
      useDHCP = false;
    };
    systemd.network.enable = true;
  }
  (lib.mkIf (lib.any (t: t) (
    lib.mapAttrsToList (_: v: v.netdevConfig.Kind == "wireguard") config.systemd.network.netdevs
  )) { environment.systemPackages = with pkgs; [ wireguard-tools ]; })
]
