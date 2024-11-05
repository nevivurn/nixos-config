{ pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    # TODO: Switch back to stable once we switch to 24.11 from 24.05
    # Use unstable due to potential RCE
    package = pkgs.pkgsUnstable.qbittorrent-nox;
    saveDir = "/data/torrents";
  };

  networking.firewall.allowedTCPPorts = [ 5555 ];
  networking.firewall.allowedUDPPorts = [ 5555 ];
}
