{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hosts";
  version = "3.15.10";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = finalAttrs.version;
    hash = "sha256-f5SH4qQzRWYKwIjpzOuhI9mPwlyNcBWjr2mrCKLgml4=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
})
