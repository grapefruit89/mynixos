/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Symbiosis
 * TRACE-ID:     NIXH-CORE-024
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:2c146b6f2ae686825ba97bab28775f46d500244ec71e9843cd81ce18fcfe9845
 */

{ config, lib, pkgs, ... }:

let
  userConfigFile = "/var/lib/nixhome/user-config.json";
  
  cpuType = config.my.configs.hardware.cpuType;
  gpuType = config.my.configs.hardware.gpuType;
  ramGB = config.my.configs.hardware.ramGB;
  
  isLowRam = ramGB <= 4;
in
{
  config = {
    # 1. CPU OPTIMIERUNG
    hardware.cpu.intel.updateMicrocode = lib.mkIf (cpuType == "intel") true;
    hardware.cpu.amd.updateMicrocode = lib.mkIf (cpuType == "amd") true;

    # 2. GPU & MULTIMEDIA SYMBIOSE
    hardware.graphics.enable = lib.mkIf (gpuType == "intel") true;
    hardware.graphics.extraPackages = lib.mkIf (gpuType == "intel") (with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ]);

    # 3. KERNEL-TUNING BASIEREND AUF CPU/GPU
    boot.kernelParams = lib.mkMerge [
      (lib.mkIf (gpuType == "intel") [ "i915.enable_guc=2" "i915.enable_fbc=1" ])
      (lib.mkIf (cpuType == "intel") [ "intel_pstate=active" ])
    ];

    # 4. RESSOURCEN-MANAGEMENT (RAM-SYMBIOSE)
    nix.settings.max-jobs = if isLowRam then lib.mkForce 1 else lib.mkForce 2;
    nix.settings.cores = if isLowRam then lib.mkForce 2 else lib.mkForce 4;
    
    zramSwap.enable = isLowRam;
    zramSwap.memoryPercent = 50;

    # 5. WARNUNG STATT ASSERTION (VM-Kompatibilität)
    warnings = lib.optional (ramGB < 4) 
      "⚠️ [HARDWARE-WARNUNG] Weniger als 4GB RAM erkannt (${toString ramGB}GB). Das System läuft im Sparmodus.";

    # 6. MOTD-Hinweis bei veraltetem Hardware-Profil
    environment.etc."nixhome-hw-age-check".source = pkgs.writeShellScript "hw-check" ''
      if [ -f "${userConfigFile}" ]; then
        AGE=$(( $(date +%s) - $(stat -c %Y "${userConfigFile}") ))
        if [ $AGE -gt 2592000 ]; then  # 30 Tage
          echo "⚠️ Hardware-Profil ist älter als 30 Tage. Ausführen: nixhome-detect-hw"
        fi
      fi
    '';

    # 7. AUTO-DISCOVERY SCRIPT
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
        
        TEMP_JSON=$(mktemp)
        echo "{\"cpu\": \"$CPU\", \"gpu\": \"$GPU\", \"ram_gb\": $RAM}" > "$TEMP_JSON"
        mv "$TEMP_JSON" ${userConfigFile}
        
        echo "✅ Hardware-Profil gespeichert."
        echo "⚠️ Bitte passe 'cpuType', 'gpuType' und 'ramGB' in /etc/nixos/10-core/configs.nix an, um die Optimierungen dauerhaft zu aktivieren."
      '')
    ];
  };
}
