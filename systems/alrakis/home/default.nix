{ inputs, ... }:

with inputs;

{
  imports = [
    self.nixosModules.home-shell
  ];
}

