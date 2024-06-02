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
}
// (
  let
    # hotfix for https://github.com/nix-community/home-manager/issues/5369
    # https://github.com/NixOS/nixpkgs/pull/316403 rebased onto release-24.05
    hotfix = builtins.getFlake "github:nevivurn/nixpkgs/0785b017e7bff11dc4ad53011319e0fb9931769e";
    pkgs = hotfix.legacyPackages.${final.system};
  in
  {
    inherit (pkgs) fcitx5;
  }
)
