/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-014
 *   title: "Logging (SRE Monitor Mode)"
 *   layer: 00
 * summary: Volatile logging with specific size and time limits to monitor log volume.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/logging/journald.nix
 * ---
 */
{ lib, ... }:
{
  # 🚀 JOURNALD SRE TUNING
  services.journald.extraConfig = ''
    # ── SPEICHER-STRATEGIE (Monitor Mode) ──────────────────────────────────
    # 'volatile' hält Logs im RAM.
    Storage=volatile
    
    # ── LIMITS (User Wunsch: 100MB Pakete, 5 Tage) ──────────────────────────
    # Wir setzen RuntimeMaxUse auf 500MB insgesamt, aber Files auf 100MB.
    RuntimeMaxUse=500M
    RuntimeMaxFileSize=100M
    
    # Lösche Logs, die älter als 5 Tage sind (im RAM)
    MaxRetentionSec=5day
    
    # ── PERFORMANCE ─────────────────────────────────────────────────────────
    Compress=yes
    RateLimitIntervalSec=30s
    RateLimitBurst=10000
    
    ForwardToSyslog=no
    ForwardToConsole=no
    
    MaxLevelStore=debug
    MaxLevelConsole=info
  '';
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
