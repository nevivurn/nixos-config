{ pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-nox.overrideAttrs (prevAttrs: {
      patches = (if prevAttrs ? patches then prevAttrs.patches else [ ]) ++ [
        (pkgs.fetchpatch2 {
          # ref: https://github.com/qbittorrent/qBittorrent/pull/24386
          name = "multi-torrent-dialogue.patch";
          url = "https://github.com/nevivurn/qBittorrent/compare/release-5.2.1...9ae23eea9.patch?full_index=1";
          hash = "sha256-QorEPQiSV3h+U/AFOU64ahnoIv9pf9Do8trvKn9OJgs=";
        })
      ];
    });
    saveDir = "/data/torrents";
  };

  networking.firewall.allowedTCPPorts = [ 5555 ];
  networking.firewall.allowedUDPPorts = [ 5555 ];
}
