{
  lib,
  buildGoModule,
  istioctl,
  rename,
}:

{
  version,
  src,
  vendorHash,
}:

let
  mainProgram = "istioctl_${version}";
  versionReplace = builtins.replaceStrings [ istioctl.version ] [ version ];
  versionRename = builtins.replaceStrings [ "istioctl" ] [ mainProgram ];
in

istioctl.override {
  buildGoModule =
    args:
    buildGoModule (
      args
      // {
        inherit version src vendorHash;

        nativeBuildInputs = args.nativeBuildInputs ++ [ rename ];

        installCheckPhase = lib.pipe args.installCheckPhase [
          versionRename
          versionReplace
        ];
        postInstall =
          args.postInstall
          + ''
            substituteInPlace \
              $out/share/bash-completion/completions/istioctl.bash \
              $out/share/zsh/site-functions/_istioctl \
              --replace-fail istioctl ${mainProgram}
            pushd $out
            find . -print0 | xargs -0 rename s/istioctl/${mainProgram}/
            popd
          '';

        ldflags = builtins.map versionReplace args.ldflags;
        meta.mainProgram = mainProgram;
      }
    );
}
