final: prev:

import ./default.nix prev
// {
  claude-code = prev.claude-code.overrideAttrs {
    postInstall = ''
      wrapProgram $out/bin/${prev.claude-code.meta.mainProgram} \
        --set CLAUDE_CODE_DISABLE_MOUSE 1
    '';
  };
}
