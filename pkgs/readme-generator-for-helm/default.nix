{ buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "readme-generator";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "bitnami";
    repo = "readme-generator-for-helm";
    rev = "refs/tags/${version}";
    hash = "sha256-hgVSiYOM33MMxVlt36aEc0uBWIG/OS0l7X7ZYNESO6A=";
  };

  npmDepsHash = "sha256-baRBchp4dBruLg0DoGq7GsgqXkI/mBBDowtAljC2Ckk=";
  dontNpmBuild = true;

  meta.mainProgram = "readme-generator";
}
