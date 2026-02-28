/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-028
 *   title: "Symbiosis"
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
        echo "⚠️ Bitte passe 'cpuType', 'gpuType' und 'ramGB' in /etc/nixos/00-core/configs.nix an, um die Optimierungen dauerhaft zu aktivieren."
      '')
    ];
  };
}









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:39bad00af0e3b27f82e6dd55eeeb45660d3b5a945e8d4b38ae191109fbbc44ed
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
