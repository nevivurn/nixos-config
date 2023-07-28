{ inputs, ... }:

with inputs;

{
  imports = [
    self.nixosModules.home-develop
  ];
}

