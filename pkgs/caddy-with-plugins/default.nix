{ lib, buildGoModule, caddy, plugins ? [ ], vendorHash, ... }:

let
  patchScript = lib.concatMapStrings
    (p: ''
      sed -i '/plug in Caddy modules here/a \\t_ "${p.name}"' cmd/caddy/main.go
    '')
    plugins;
  getScript = lib.concatMapStrings
    (p: ''
      go get ${p.name}@${p.version or "latest"}
    '')
    plugins;
in

caddy.override (_: {
  buildGoModule = args: buildGoModule (args // {
    postPatch = patchScript;
    postConfigure = ''
      cp vendor/go.mod vendor/go.sum ./
    '';

    overrideModAttrs = (_: {
      postConfigure = getScript;
      postInstall = ''
        cp go.mod go.sum $out/
      '';
    });

    inherit vendorHash;
  });
})
