/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-034
 *   title: "Zram Swap (RAM-Efficiency)"
 *   layer: 00
 * summary: Compressed RAM swap tuning for high performance without SSD wear.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/zram-swap.nix
 * ---
 */
{ config, lib, ... }:
let
  ramGB = config.my.configs.hardware.ramGB;
in
{
  # ── ZRAM TUNING ──────────────────────────────────────────────────────────
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Beste Ratio/Speed-Balance für 2026
    memoryPercent = if ramGB <= 4 then 75
                     else if ramGB <= 8 then 50
                     else 25;
  };

  # ── KERNEL OPTIMIERUNG (SRE Standard) ───────────────────────────────────
  boot.kernel.sysctl = {
    # Aggressiv in zram swappen (verhindert OOM bei hoher Last)
    "vm.swappiness" = lib.mkForce 180;
    # Kein Read-Ahead nötig bei ZRAM
    "vm.page-cluster" = lib.mkDefault 0;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
