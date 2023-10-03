{
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings.PasswordAuthentication = false;
  };

  environment.enableAllTerminfo = true;
}
