{
  services.inadyn = {
    enable = true;
    settings.provider = {
      "default@cloudflare.com" = {
        hostname = "public.nevi.network";
        username = "nevi.network";
        include = "/secrets/inadyn-cf-nevi-network";
      };
    };
  };
}
