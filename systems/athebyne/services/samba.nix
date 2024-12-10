{ pkgs, ... }:

{
  services.samba = {
    enable = true;
    settings.global = {
      "guest account" = "nobody";
      "map to guest" = "bad user";
      "usershare allow guests" = "yes";
      "usershare owner only" = "no";
      "usershare max shares" = 10;
      "allow insecure wide links" = "yes";
      "wide links" = "yes";
    };
    openFirewall = true;
  };

  systemd.services.samba-smbd.serviceConfig.ExecStartPre =
    "${pkgs.coreutils}/bin/mkdir -m +t -p /var/lib/samba/usershares/";

  environment.persistence = {
    "/persist".directories = [ "/var/lib/samba/usershares" ];
  };
}
