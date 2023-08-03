{ inputs, ... }:

with inputs;

{
  imports = [
    self.homeModules.sway
  ];
}
