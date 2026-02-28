{ config, lib, pkgs, ... }:
let
  userConfigFile = "/var/lib/nixhome/user-config.json";
  userConfig = if builtins.pathExists userConfigFile 
               then builtins.fromJSON (builtins.readFile userConfigFile)
               else {};

  get = attr: default: if userConfig ? ${attr} then userConfig.${attr} else default;

  cpuType = get "cpu" "intel";
  gpuType = get "gpu" "intel";
  ramGB = get "ram_gb" 16;
  
  isLowRam = ramGB <= 4;
in
{
  # 🧠 INTELLIGENTE HARDWARE-SOFTWARE-SYMBIOSE
  config = {
    # 1. CPU OPTIMIERUNG
    hardware.cpu.intel.updateMicrocode = lib.mkIf (cpuType == "intel") true;
    hardware.cpu.amd.updateMicrocode = lib.mkIf (cpuType == "amd") true;

    # 2. GPU & MULTIMEDIA SYMBIOSE
    hardware.graphics = lib.mkIf (gpuType == "intel") {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };

    # 3. KERNEL-TUNING BASIEREND AUF CPU/GPU
    boot.kernelParams = lib.mkMerge [
      (lib.mkIf (gpuType == "intel") [ "i915.enable_guc=2" "i915.enable_fbc=1" ])
      (lib.mkIf (cpuType == "intel") [ "intel_pstate=active" ])
    ];

    # 4. RESSOURCEN-MANAGEMENT (RAM-SYMBIOSE)
    nix.settings = {
      max-jobs = if isLowRam then lib.mkForce 1 else lib.mkForce 2;
      cores = if isLowRam then lib.mkForce 2 else lib.mkForce 4;
    };
    
    zramSwap.enable = isLowRam;
    zramSwap.memoryPercent = 50;

    # 5. HARDWARE-ASSERTION
    assertions = [
      {
        assertion = ramGB >= 4;
        message = "❌ [HARDWARE-ERROR] Weniger als 4GB RAM erkannt (${toString ramGB}GB). Das ist kein ernstzunehmender Media-Server! Abbruch zum Schutz der Hardware-Stabilität.";
      }
    ];

    # 6. AUTO-DISCOVERY SCRIPT
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nixhome-detect-hw" ''
        set -euo pipefail
        echo "🔍 Starte Hardware-Auto-Discovery..."
        
        CPU="intel"
        if grep -q "AMD" /proc/cpuinfo; then CPU="amd"; fi
        
        GPU="none"
        if lspci | grep -qi "Intel.*VGA"; then GPU="intel"; fi
        if lspci | grep -qi "NVIDIA"; then GPU="nvidia"; fi
        
        RAM=$(free -g | awk '/^Speicher:/ {print $2}')
        
        echo "Gefunden: CPU=$CPU, GPU=$GPU, RAM=''${RAM}GB"
        
        if [ "$RAM" -lt 4 ]; then
          echo "❌ FEHLER: Nur ''${RAM}GB RAM gefunden. Minimum für nixhome ist 4GB!"
          exit 1
        fi
        
        TEMP_JSON=$(mktemp)
        if [ -f ${userConfigFile} ]; then
          ${pkgs.jq}/bin/jq --arg cpu "$CPU" --arg gpu "$GPU" --argjson ram "$RAM" \
            '. + {cpu: $cpu, gpu: $gpu, ram_gb: $ram}' ${userConfigFile} > "$TEMP_JSON"
        else
          echo "{\"cpu\": \"$CPU\", \"gpu\": \"$GPU\", \"ram_gb\": $RAM}" > "$TEMP_JSON"
        fi
        
        mv "$TEMP_JSON" ${userConfigFile}
        echo "✅ Hardware-Profil gespeichert."
        nixhome-apply
      '')
    ];
  };
}
