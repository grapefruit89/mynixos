/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Nix Daemon Tuning
 * TRACE-ID:     NIXH-CORE-002
 * PURPOSE:      Optimierung des Nix-Builders, Binary Caches und OOM-Schutz.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ config, lib, pkgs, ... }:

let
  # Erkennung von wenig RAM (<= 4GB)
  # Wir nutzen hier den Wert aus der Hardware-Config
  ramGB = config.my.configs.hardware.ramGB or 16; 
  isLowRam = ramGB <= 4;
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
      # "nixhome.cachix.org-1:DEIN_PUBLIC_KEY_HIER_INSERT" # Auskommentiert bis echter Key da ist
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # 1. DOWNLOADS PRIORISIEREN
    # Versuche immer erst den Download, auch bei Abhängigkeiten von Abhängigkeiten.
    builders-use-substitutes = true;

    # 2. DER NOTFALL-FALLBACK
    # Falls das Paket nicht im Cache ist: Baue es lokal, anstatt abzubrechen.
    fallback = true;

    # 🛡️ OOM-SCHUTZ (Optimiert für 4GB RAM)
    # Verhindert, dass der Rebuild das System einfriert
    max-jobs = if isLowRam then lib.mkForce 1 else lib.mkDefault 1;
    cores = if isLowRam then lib.mkForce 2 else lib.mkDefault 1; # Nutze pro Job nur einen Kern um System flüssig zu halten.
    
    # Automatische Optimierung des Stores (Hardlinks sparen Platz auf dem Stick)
    auto-optimise-store = true;
    
    # Experimentelle Features für 2026 Standard
    experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
    
    # Sandbox für Sicherheit
    sandbox = true;
  };

  # Assertion gegen Platzhalter-Keys
  assertions = [
    {
      assertion = !(lib.any (k: lib.hasInfix "DEIN_PUBLIC_KEY_HIER_INSERT" k) config.nix.settings.trusted-public-keys);
      message = "nix-tuning: Bitte trage einen echten Cachix-Key ein oder entferne den Platzhalter!";
    }
  ];

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
