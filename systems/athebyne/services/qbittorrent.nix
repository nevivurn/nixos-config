{ pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-nox.overrideAttrs (prevAttrs: {
      patches = (if prevAttrs ? patches then prevAttrs.patches else [ ]) ++ [
        (pkgs.fetchpatch2 {
          # ref: https://github.com/qbittorrent/qBittorrent/pull/24386
          name = "multi-torrent-dialogue.patch";
          url = "https://github.com/nevivurn/qBittorrent/compare/release-5.2.1...nevivurn:qBittorrent:rebased/tom/shared-download-window.patch?full_index=1";
          hash = "sha256-dNbnHJSjtyyS8LKbQahGtWEtx9VEhkSDze1+uUIdPLo=";
        })
      ];
    });
    saveDir = "/data/torrents";
  };

  networking.firewall.allowedTCPPorts = [ 5555 ];
  networking.firewall.allowedUDPPorts = [ 5555 ];
}
