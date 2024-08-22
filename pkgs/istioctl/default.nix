{
  lib,
  buildGoModule,
  istioctl,
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
        installCheckPhase = lib.pipe args.installCheckPhase [
          versionRename
          versionReplace
        ];
        postInstall = ''
          mv $out/bin/istioctl $out/bin/${mainProgram}
        ''; # do not install completion for now

        ldflags = builtins.map versionReplace args.ldflags;
        meta.mainProgram = mainProgram;
      }
    );
}
