final: prev:

import ./default.nix prev
// {
  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [ ./gnucash/krw-no-fraction.patch ];
  });

  # Add caddy.withModules
  caddy = prev.caddy.overrideAttrs (prev: {
    passthru.withModules =
      { plugins, vendorHash }:
      let
        patchScript = final.lib.concatMapStrings (p: ''
          sed -i '/plug in Caddy modules here/a \\t_ "${p.name}"' cmd/caddy/main.go
        '') plugins;
        getScript = final.lib.concatMapStrings (p: ''
          go get ${p.name}@${p.version or "latest"}
        '') plugins;
      in
      final.caddy.override {
        buildGoModule =
          args:
          final.buildGoModule (
            args
            // {
              postPatch = patchScript;
              postConfigure = ''
                cp vendor/go.mod vendor/go.sum ./
              '';

              overrideModAttrs = _: {
                postConfigure = getScript;
                postInstall = ''
                  cp go.mod go.sum $out/
                '';
              };

              inherit vendorHash;
            }
          );
      };
  });

  istioctl = prev.istioctl.overrideAttrs { passthru.withVersion = final.callPackage ./istioctl { }; };
  istioctl_1_20 = final.istioctl.withVersion rec {
    version = "1.20.7";
    src = final.fetchFromGitHub {
      owner = "istio";
      repo = "istio";
      rev = version;
      hash = "sha256-1FcrjCxnGUcgBAU5hLJmuU4XfoJlRvJwBCIndLinvlA=";
    };
    vendorHash = "sha256-IwGFeEvioAjjhwFjq6/S1ZvDWd1qJHnZdsKnw1kf9dE=";
  };

  kubectl = prev.kubectl.overrideAttrs { passthru.withVersion = final.callPackage ./kubectl { }; };
  kubectl_1_28 = final.kubectl.withVersion rec {
    version = "1.28.14";
    src = final.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v${version}";
      hash = "sha256-CMboT7c3z4A3/rhuky27y/JzW91PhkspeZWQw8swXBI=";
    };
  };
  kubectl_1_29 = final.kubectl.withVersion rec {
    version = "1.29.9";
    src = final.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v${version}";
      hash = "sha256-XLtNITqeVallN7vhZxvgjJsuWHYi0vm2ru9OaahU+nM=";
    };
  };
}
