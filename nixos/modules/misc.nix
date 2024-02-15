{
  services.irqbalance.enable = true;

  boot.kernel.sysctl = {
    # I have no idea what I'm doing, but this improves throughput significantly
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # MITM certificate from funi
  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIBozCCAUqgAwIBAgIRAPgffsUgkjfBw87oxCN5ABAwCgYIKoZIzj0EAwIwMDEu
      MCwGA1UEAxMlQ2FkZHkgTG9jYWwgQXV0aG9yaXR5IC0gMjAyNCBFQ0MgUm9vdDAe
      Fw0yNDAyMTUxNDA4MTRaFw0zMzEyMjQxNDA4MTRaMDAxLjAsBgNVBAMTJUNhZGR5
      IExvY2FsIEF1dGhvcml0eSAtIDIwMjQgRUNDIFJvb3QwWTATBgcqhkjOPQIBBggq
      hkjOPQMBBwNCAAQzRa2NrgDWiCE859U5J77GgxUk7AGstEUFkZPZI+IEJe02XYXY
      JnG0kj+5jxfru7lXfdRJx20MoV67aFB4bhoBo0UwQzAOBgNVHQ8BAf8EBAMCAQYw
      EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUl4Vzyq6XcXRByzt9nEipj184
      Wh8wCgYIKoZIzj0EAwIDRwAwRAIgOgEX/Nv0cLgZmzlE4M+ouMjXU1UoHbfbKVAT
      zXq44OICIEtjU3OE5abWAJRkfrkQzee6KoImzqlSAlZ2wHnLU+qb
      -----END CERTIFICATE-----
    ''
  ];
}
