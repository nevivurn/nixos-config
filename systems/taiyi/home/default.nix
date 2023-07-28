{ inputs, ... }:

with inputs;

{
  imports = [
    self.homeConfigurations.sway
  ];
}
