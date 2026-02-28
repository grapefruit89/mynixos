{ config, lib, pkgs, ... }:
let
  # Erkennung von wenig RAM (<= 4GB)
  isLowRam = config.boot.kernelParams != [] && (lib.any (p: lib.hasPrefix "mem=" p) config.boot.kernelParams || true); # Vereinfachte Annahme für Stick-Betrieb
in
{
  # 🚀 NIX-DAEMON OPTIMIERUNGEN (Phase 3)
  nix.settings = {
    # 📦 BINARY CACHE (Cachix)
    # Verhindert lokales Kompilieren auf dem Stick
    substituters = [
      "https://cache.nixos.org"
      "https://nixhome.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixhome.cachix.org-1:DEIN_PUBLIC_KEY_HIER_INSERT" # Platzhalter für späteren Key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # 🛡️ OOM-SCHUTZ (Optimiert für 4GB RAM)
    # Verhindert, dass der Rebuild das System einfriert
    max-jobs = lib.mkDefault 2;
    cores = lib.mkDefault 2;
    
    # Automatische Optimierung des Stores (Hardlinks sparen Platz auf dem Stick)
    auto-optimise-store = true;
    
    # Experimentelle Features für 2026 Standard
    experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
    
    # Sandbox für Sicherheit
    sandbox = true;
  };

  # 💨 PERFORMANCE TUNING
  # Build-Prozesse auf niedrige Priorität setzen (System bleibt bedienbar)
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # 🧹 AUTOMATISCHE REINIGUNG
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Tooling für Phase 3
  environment.systemPackages = with pkgs; [
    cachix
    nix-tree # Visualisierung des Store-Verbrauchs
  ];
}
