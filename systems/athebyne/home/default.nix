{ inputs, ... }:

with inputs;

{
  imports = [
    self.homeConfigurations.develop
  ];
}

