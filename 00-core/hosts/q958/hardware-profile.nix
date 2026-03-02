# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Spezifisches Hardware-Profil für Fujitsu Q958 (i3-9100 / UHD 630)

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.hardware.q958;
in
{
  config = lib.mkIf cfg.enable {
    # ── CPU & FIRMWARE ───────────────────────────────────────────────────────
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.firmware = [ pkgs.linux-firmware ];

    # ── GRAFIK & KERNEL (Intel UHD 630) ──────────────────────────────────────
    boot.kernelParams = [ 
      "i915.enable_guc=2"  # GuC/HuC Firmware für 9th Gen
      "i915.enable_fbc=1"  # Framebuffer Compression
    ];
    boot.kernelModules = [ "i915" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver    # iHD Treiber
        intel-compute-runtime # OpenCL
        vpl-gpu-rt            # Video Processing Library
      ];
    };

    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

    # ── TOOLS ────────────────────────────────────────────────────────────────
    environment.systemPackages = with pkgs; [
      libva-utils       # vainfo
      intel-gpu-tools   # intel_gpu_top
    ];

    # ── USER GROUPS ──────────────────────────────────────────────────────────
    users.users.${config.my.configs.identity.user}.extraGroups = [ "video" "render" ];

    # ── STORAGE ──────────────────────────────────────────────────────────────
    # hd-idle Modul scheint im aktuellen Channel nicht vorhanden zu sein.
    # TODO: Manuellen systemd-Dienst erstellen falls nötig.
    # services.hd-idle = {
    #   enable = true;
    #   idletime = 600;
    # };
  };
}
