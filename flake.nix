{
  description = "NixHome - Aviation Grade Homelab Configuration";

  inputs = {
    # 🚀 UPGRADE: Nutzt die aktuellste Stable Version für 2026
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # Alternative für Bleeding Edge: "github:nixos/nixpkgs/nixos-unstable"
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
