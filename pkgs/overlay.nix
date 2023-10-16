final: prev:

import ./default.nix prev //

{
  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [
      ./gnucash/krw-no-fraction.patch
      ./gnucash/extra-quote-sources.patch
    ];
  });

  # Add caddy.withModules
  caddy = prev.caddy.overrideAttrs (prev: {
    passthru.withModules = { plugins, vendorHash }:
      let
        patchScript = final.lib.concatMapStrings
          (p: ''
            sed -i '/plug in Caddy modules here/a \\t_ "${p.name}"' cmd/caddy/main.go
          '')
          plugins;
        getScript = final.lib.concatMapStrings
          (p: ''
            go get ${p.name}@${p.version or "latest"}
          '')
          plugins;
      in

      final.caddy.override {
        buildGoModule = args: final.buildGoModule (args // {
          postPatch = patchScript;
          postConfigure = ''
            ls
            cp vendor/go.mod vendor/go.sum ./
          '';

          overrideModAttrs = _: {
            postConfigure = getScript;
            postInstall = ''
              cp go.mod go.sum $out/
            '';
          };

          inherit vendorHash;
        });
      }
    ;
  });

  firefox = if final.stdenv.isDarwin then final.callPackage ./firefox-darwin { } else prev.firefox;
}
