{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    openFirewall = false;
  };
  networking.firewall.interfaces = {
    wg-proxy.allowedTCPPorts = [ 22 ];
    wg51.allowedTCPPorts = [ 22 ];
    wg52.allowedTCPPorts = [ 22 ];
  };
}
