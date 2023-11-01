{ config, pkgs, ... }:

let cfg = config.services.kavita; in
{
  services.kavita = {
    enable = true;
    package = pkgs.pkgsUnstable.kavita.overrideAttrs (prev: {
      frontend = prev.frontend.overrideAttrs {
        postPatch = ''
          sed -i 's|base href="/"|base href="${cfg.settings.BaseUrl}"|' src/index.html
        '';
      };
    });

    tokenKeyFile = "/persist/secrets/kavita-token";
    settings = {
      IpAddresses = "127.0.0.1,::1";
      BaseUrl = "/kavita/";
    };
  };

  environment.persistence = {
    "/persist".directories = [ cfg.dataDir ];
  };
}
