{ lib, runCommand, makeWrapper, kubectl, plugins ? [ ] }:

runCommand "kubectl-with-plugins"
{
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir $out
  ln -s ${kubectl}/share $out/share

  mkdir -p $out/bin
  makeWrapper ${kubectl}/bin/kubectl $out/bin/kubectl \
    --prefix PATH : ${lib.makeBinPath plugins}
''
