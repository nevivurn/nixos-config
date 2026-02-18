{
  lib,
  stdenvNoCC,
  python3,
  openssh,
  makeWrapper,
}:

stdenvNoCC.mkDerivation {
  name = "ssh-keygen-gpg-wrapper";

  src = ./ssh-keygen-gpg-wrapper.py;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/ssh-keygen
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/ssh-keygen \
      --prefix PATH : ${lib.makeBinPath [ openssh ]}
  '';

  meta.mainProgram = "ssh-keygen";
}
