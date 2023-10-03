# upstream to nixpkgs if it works well
{ lib
, fetchFromGitHub
, stdenv
, rustPlatform
, CoreServices
}:

rustPlatform.buildRustPackage rec {
  pname = "unison-fsmonitor";
  version = "v0.3.3";

  src = fetchFromGitHub {
    owner = "autozimu";
    repo = "unison-fsmonitor";
    rev = version;
    hash = "sha256-JA0WcHHDNuQOal/Zy3yDb+O3acZN3rVX1hh0rOtRR+8=";
  };
  cargoSha256 = "sha256-169ff9FSKNLlalGVI/kc+xNowQpqFAahFUKF8Fgz5vE=";

  buildInputs = lib.optionals stdenv.isDarwin [ CoreServices ];

  meta = {
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
