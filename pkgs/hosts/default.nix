{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hosts";
  version = "3.14.104";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = finalAttrs.version;
    hash = "sha256-APxlS1c68AGOGUBv/SVHTFDYuvMZHxFVEqXDlfEJlqk=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
})
