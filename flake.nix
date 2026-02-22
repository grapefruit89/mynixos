{
  description = "Moritz Q958 NixOS Konfiguration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, sops-nix, flake-utils, ... }@inputs: {
    nixosConfigurations.q958 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # Alle Inputs für Module verfügbar machen
      modules = [
        # Host-spezifische Konfiguration importieren
        ./hosts/q958

        # sops-nix Modul importieren, um Geheimnisse zu verwalten
        sops-nix.nixosModules.sops
      ];
    };
  };
}
