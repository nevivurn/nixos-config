{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    openFirewall = false;
  };
  networking.firewall.interfaces."wg-proxy".allowedTCPPorts = [ 22 ];
}
