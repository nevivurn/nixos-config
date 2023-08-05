{
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings.PasswordAuthentication = false;
  };

  environment.enableAllTerminfo = true;

  networking.firewall.interfaces.br-lan.allowedTCPPorts = [ 22 ];
}
