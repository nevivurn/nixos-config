{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  environment.enableAllTerminfo = true;

  environment.persistence = {
    "/persist".files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
