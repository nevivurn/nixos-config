# nixos-config
Personal Nix(OS) configuration.

## Structure

```
├── nixos               # shared NixOS config
│   ├── modules         # generic config imported by most configs
│   └── profiles        # presets
│       └── graphical
├── home                # shared home-manager config
│   ├── modules         # generic config imported by most configs
│   └── profiles        # presets
│       ├── shell
│       ├── develop
│       └── graphical
├── pkgs                # custom packages
│   ├── default.nix     # root overlay
│   └── <package>
└── systems             # per-system config
    └── <host>
        ├── default.nix # root config
        ├── services    # per-service config
        ├── hardware-configuration.nix # generated with nixos-generate-config --no-filesystems --show-hardware-config  2>/dev/null
        └── home        # per-system home config
            └── default.nix # root config
```
