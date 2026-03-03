{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-013";
    title = "Host Q958 Hardware Profile";
    description = "Specific hardware optimizations for Fujitsu Q958 (i3-9100 / UHD 630).";
    layer = 00;
    nixpkgs.category = "hardware/graphics";
    capabilities = [ "gpu/intel-qsv" "hardware/firmware" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  cfg = config.my.profiles.hardware.q958;
in
{
  options.my.meta.host_q958_hardware_profile = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for host-q958-hardware-profile module";
  };

  config = lib.mkIf cfg.enable {
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.firmware = [ pkgs.linux-firmware ];

    boot.kernelParams = [ "i915.enable_guc=2" "i915.enable_fbc=1" ];
    boot.kernelModules = [ "i915" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };

    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    environment.systemPackages = with pkgs; [ libva-utils intel-gpu-tools ];
    users.users.${config.my.configs.identity.user}.extraGroups = [ "video" "render" ];
  };
}
