/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-034
 *   title: "Zram Swap"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  ramGB = config.my.configs.hardware.ramGB;
in
{
  # ZRAM: Komprimierter RAM-Swap (schneller als Disk, kein I/O-Wear)
  # Für 16GB RAM: 25% = 4GB zram (zstd komprimiert ~2:1 → effektiv 8GB)
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd"; # Beste Ratio/Speed-Balance
  zramSwap.memoryPercent = if ramGB <= 4 then 75
                           else if ramGB <= 8 then 50
                           else 25;

  # Kernel-Tuning für zram-optimierten Betrieb
  boot.kernel.sysctl."vm.swappiness" = lib.mkForce 180; # Aggressiv in zram
  boot.kernel.sysctl."vm.page-cluster" = lib.mkDefault 0; # Kein Read-Ahead
}


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:41fc1732e8e3b5f133b3c1c256f2d782fc06763ee4c58c5a505eb159066ff5b5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
