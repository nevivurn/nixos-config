{
  services.qbittorrent.enable = true;
  services.qbittorrent.saveDir = "/data/torrents";

  networking.firewall.allowedTCPPorts = [ 5555 ];
  networking.firewall.allowedUDPPorts = [ 5555 ];
}
