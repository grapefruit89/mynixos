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
  ramGB = config.my.configs.hardware.ramGB;
  isLowRam = ramGB <= 4;
in
{
  config = {
    # CPU-Microcode Updates
    hardware.cpu.intel.updateMicrocode = lib.mkIf (cpuType == "intel") true;
    hardware.cpu.amd.updateMicrocode = lib.mkIf (cpuType == "amd") true;

    # RAM-Symbiose (ZRAM)
    zramSwap.enable = isLowRam;
    zramSwap.memoryPercent = 50;

    # VM/Hardware Warnung
    warnings = lib.optional (ramGB < 4) 
      "⚠️ [HARDWARE-WARNUNG] Weniger als 4GB RAM erkannt (${toString ramGB}GB). Das System läuft im Sparmodus.";

    # MOTD-Hinweis bei veraltetem Hardware-Profil
    environment.etc."nixhome-hw-age-check".source = pkgs.writeShellScript "hw-check" ''
      if [ -f "${userConfigFile}" ]; then
        AGE=$(( $(date +%s) - $(stat -c %Y "${userConfigFile}") ))
        if [ $AGE -gt 2592000 ]; then  # 30 Tage
          echo "⚠️ Hardware-Profil ist älter als 30 Tage. Ausführen: nixhome-detect-hw"
        fi
      fi
    '';

    # AUTO-DISCOVERY SCRIPT
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nixhome-detect-hw" ''
        set -euo pipefail
        echo "🔍 Starte Hardware-Auto-Discovery..."
        CPU="intel"; if grep -q "AMD" /proc/cpuinfo; then CPU="amd"; fi
        GPU="none"; if lspci | grep -qi "Intel.*VGA"; then GPU="intel"; fi
        if lspci | grep -qi "NVIDIA"; then GPU="nvidia"; fi
        RAM=$(free -g | awk '/^Speicher:/ {print $2}')
        echo "Gefunden: CPU=$CPU, GPU=$GPU, RAM=''${RAM}GB"
        TEMP_JSON=$(mktemp); echo "{\"cpu\": \"$CPU\", \"gpu\": \"$GPU\", \"ram_gb\": $RAM}" > "$TEMP_JSON"
        mv "$TEMP_JSON" ${userConfigFile}
        echo "✅ Hardware-Profil gespeichert."
      '')
    ];
  };
}


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:4b80d9698d702a3dbc72fe33c9660a1c071fd12f6e32bd46cb7f07f9a1b3b220
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
