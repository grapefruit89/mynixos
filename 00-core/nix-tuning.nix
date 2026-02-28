/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-017
 *   title: "Nix Tuning"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  ramGB = config.my.configs.hardware.ramGB;
  isLowRam = ramGB <= 4;
  isMidRam = ramGB > 4 && ramGB <= 8;
in
{
  # ── BINARY CACHES ─────────────────────────────────────────────────────────
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # ── STORE OPTIMIERUNG ────────────────────────────────────────────────────
  nix.settings.auto-optimise-store = true;
  nix.settings.builders-use-substitutes = true;
  nix.settings.fallback = true;

  # GC-Roots für schnelleres Rebuilding erhalten
  nix.settings.keep-outputs = true;
  nix.settings.keep-derivations = true;

  # Negativ-Cache verkürzen (schnellere Fallback-Erkennung)
  nix.settings.narinfo-cache-negative-ttl = 0;

  # ── RESSOURCEN-MANAGEMENT ────────────────────────────────────────────────
  nix.settings.max-jobs = if isLowRam then lib.mkForce 1
                          else if isMidRam then lib.mkForce 2
                          else lib.mkDefault 4;
  nix.settings.cores = if isLowRam then lib.mkForce 1
                       else if isMidRam then lib.mkForce 2
                       else lib.mkDefault 0;

  # Build-Timeout verhindert hängende Builds
  nix.settings.timeout = 3600;  # 1h Max pro Build
  nix.settings.max-silent-time = 600;   # 10min Stille = Fehler

  nix.settings.experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
  nix.settings.sandbox = true;
  nix.settings.trusted-users = [ "root" config.my.configs.identity.user ];

  # ── CPU & IO PRIORITÄT ───────────────────────────────────────────────────
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;

  # ── GC ───────────────────────────────────────────────────────────────────
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";
  nix.gc.persistent = true;

  # ── TOOLING ──────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    cachix nix-tree nix-diff nix-output-monitor nix-du
  ];

  assertions = [{
    assertion = !(lib.any (k: lib.hasInfix "DEIN_PUBLIC_KEY_HIER_INSERT" k) config.nix.settings.trusted-public-keys);
    message = "nix-tuning: Platzhalter-Key aktiv. Bitte echten Key eintragen!";
  }];
}


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:3177fcffcf0d03cecbe3ef976de4f6b762265af95be35bc79acc69e0106d24cf
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
