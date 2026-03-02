{
  description = "NixHome - Aviation Grade Homelab Configuration";

  inputs = {
    # 🚀 UPGRADE: Nutzt die aktuellste Stable Version für 2026
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # Alternative für Bleeding Edge: "github:nixos/nixpkgs/nixos-unstable"
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      nixhome = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
