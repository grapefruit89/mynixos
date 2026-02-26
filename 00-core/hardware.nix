# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Hardware-spezifische Optimierungen (Cockpit-gesteuert)

{ config, lib, pkgs, ... }:
let
  cfg = config.my.configs.hardware;
in
{
  # source-id: CFG.hardware.cpuMicrocode
  # sink: CPU Microcode Updates (Security/Stability)
  hardware.cpu.intel.updateMicrocode = lib.mkIf cfg.updateMicrocode (lib.mkDefault config.hardware.enableRedistributableFirmware);

  # source-id: CFG.hardware.intelGpu
  # sink: Kernel-Parameter und Module für UHD 630 Performance
  boot = lib.mkIf cfg.intelGpu {
    kernelParams = [ "i915.enable_guc=2" ];
    kernelModules = [ "i915" ];
  };

  # Zusätzliche Grafik-Treiber für Intel
  hardware.graphics = lib.mkIf cfg.intelGpu {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
}
