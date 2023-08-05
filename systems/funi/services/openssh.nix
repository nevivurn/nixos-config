{
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings.PasswordAuthentication = false;
  };

  networking.firewall.interfaces.br-lan.allowedTCPPorts = [ 22 ];
}
