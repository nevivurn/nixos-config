{ inputs, ... }:

with inputs;

{
  imports = [
    self.homeConfigurations.shell
  ];
}

