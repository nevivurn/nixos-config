{ lib, stdenvNoCC, makeWrapper, bash, pass }:

stdenvNoCC.mkDerivation {
  name = "passmenu";
  src = builtins.path { path = ./.; name = "passmenu"; };

  buildInputs = [ bash pass ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m0755 passmenu $out/bin/
    wrapProgram $out/bin/passmenu \
      --prefix PATH : ${lib.makeBinPath [ pass ]}
    runHook postInstall
  '';
}
