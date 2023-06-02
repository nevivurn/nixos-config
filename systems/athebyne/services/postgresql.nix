{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;

    # initialize matrix-synapse DB
    initialScript = pkgs.writeText "" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN;
      CREATE DATABASE "matrix-synapse" WITH
        OWNER "matrix-synapse"
        LOCALE "C"
        ENCODING "utf-8"
        TEMPLATE template0;
    '';
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/postgresql" ];
  };
}
