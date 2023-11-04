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

  # ref:
  # - https://gitlab.freedesktop.org/mesa/mesa/-/issues/9009
  # - https://gitlab.freedesktop.org/mesa/mesa/-/commit/2c1da7fbde06900433993fda7813114510d59c0c
  # doesn't fix ffmpeg segfaults, hopefully fixed on 23.11? (23.3)
  mesa = prev.mesa.overrideAttrs (finalAttrs: prevAttrs: {
    patches = prevAttrs.patches
    ++ final.lib.optionals (final.lib.versionOlder finalAttrs.version "23.1") [
      (final.fetchpatch {
        name = "mpv-segfault-patch";
        url = "https://gitlab.freedesktop.org/mesa/mesa/-/commit/2c1da7fbde06900433993fda7813114510d59c0c.patch";
        hash = "sha256-RMw6T4WAwoitjYO0PINGLFiOApGaN6rkgD2Da4iEeYI=";
      })
    ];
  });
}
