{
  services.nfs.server.enable = true;
  networking.firewall.allowedTCPPorts = [ 111 2049 ];
  networking.firewall.allowedUDPPorts = [ 111 ];
}
