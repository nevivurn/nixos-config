{ inputs, ... }:

with inputs;

{
  imports = [
    self.homeModules.shell
  ];
}
