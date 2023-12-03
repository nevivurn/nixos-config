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

  vimPlugins = prev.vimPlugins.extend (_: _: {
    tree-sitter-templ = final.vimUtils.buildVimPlugin {
      pname = "tree-sitter-templ";
      version = "2023-10-28";
      src = final.fetchFromGitHub {
        owner = "vrischmann";
        repo = "tree-sitter-templ";
        rev = "89e5957b47707b16be1832a2753367b91fb85be0";
        hash = "sha256-nNC0mMsn5KAheFqOQNbbcXYnyd2S8EoGc1k+1Zi6PVc=";
      };
    };
  });
}
