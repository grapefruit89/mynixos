{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-034";
    title = "Zram Swap (RAM-Efficiency)";
    description = "Compressed RAM swap tuning for high performance without SSD wear.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "system/performance" "hardware/ram-optimization" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  ramGB = config.my.configs.hardware.ramGB;
in
{
  options.my.meta.zram_swap = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for zram-swap module";
  };

  config = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = if ramGB <= 4 then 75 else if ramGB <= 8 then 50 else 25;
    };
    boot.kernel.sysctl = { "vm.swappiness" = lib.mkForce 180; "vm.page-cluster" = lib.mkDefault 0; };
  };
}
