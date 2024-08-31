{
  lib,
  kubectl,
  kubernetes,
  buildGoModule,
  rename,
}:

{ version, src }:

let
  mainProgram = "kubectl_${version}";
in

kubectl.override {
  kubernetes = kubernetes.override {
    buildGoModule =
      args:
      buildGoModule (
        args
        // {
          inherit version src;

          nativeBuildInputs = args.nativeBuildInputs ++ [ rename ];

          postInstall =
            ''
              substituteInPlace \
                $out/share/bash-completion/completions/kubectl.bash \
                $out/share/fish/vendor_completions.d/kubectl.fish \
                $out/share/zsh/site-functions/_kubectl \
                --replace-fail kubectl ${mainProgram}
            ''
            + (lib.concatMapStrings (out: ''
              if [[ -d ''$${out} ]]; then
                pushd ''$${out}
                find . -print0 | xargs -0 rename s/kubectl/${mainProgram}/
                popd
              fi
            '') args.outputs);
        }
      );
  };
}
