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
 *   checksum: sha256:d7028d0a6ced17d1a3427c054e6372be7cdeadd952054fc9b650447753ca3cd1
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
