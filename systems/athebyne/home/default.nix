{ inputs, ... }:

with inputs;

{
  imports = [
    self.homeModules.develop
  ];
}
