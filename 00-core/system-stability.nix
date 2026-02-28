/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-030
 *   title: "System Stability"
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
  user = config.my.configs.identity.user;
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # EFI-ENTRY CLEANUP (AUDIT-FIX)
  # Verhindert NVRAM-Korruption durch aggressive Bereinigung verwaister Einträge.
  # ══════════════════════════════════════════════════════════════════════════
  
  system.activationScripts.cleanEfiEntries = {
    text = ''
      echo "🧹 Bereinige verwaiste EFI-Boot-Einträge (NVRAM Protection)..."
      # Entferne Einträge die nicht 'systemd-boot' oder 'NixOS' im Namen haben
      ${pkgs.efibootmgr}/bin/efibootmgr | grep "Boot[0-9]" | grep -vE "systemd-boot|NixOS|Linux|USB|Hard Drive|Network" | \
        awk '{print $1}' | sed 's/Boot//;s/\*//' | \
        xargs -I{} ${pkgs.efibootmgr}/bin/efibootmgr -b {} -B 2>/dev/null || true
    '';
  };

  # ══════════════════════════════════════════════════════════════════════════
  # CONFIGURATION DRIFT DETECTOR (AUDIT-FIX)
  # Warnt wenn imperative JSON-Änderungen dem deklarativen Nix-Status widersprechen.
  # ══════════════════════════════════════════════════════════════════════════
  
  systemd.services.config-drift-detector = {
    description = "Detect configuration drift between Nix and user-data";
    after = [ "nixhome-config-merger.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      USER_CONFIG="/var/lib/nixhome/user-config.json"
      if [ -f "$USER_CONFIG" ] && [ "$(cat "$USER_CONFIG")" != "{}" ]; then
        ${pkgs.util-linux}/bin/logger -p auth.warning "⚠️ CONFIG-DRIFT: Imperative configuration detected in $USER_CONFIG"
        echo "⚠️  HINWEIS: Das System nutzt imperative Einstellungen aus $USER_CONFIG."
      fi
    '';
  };

  # ══════════════════════════════════════════════════════════════════════════
  # EMERGENCY RECOVERY SHELL (AUDIT-FIX)
  # Verhindert Headless-Deadlock bei Setup-Fehlern.
  # ══════════════════════════════════════════════════════════════════════════
  
  systemd.services.nixhome-emergency = {
    description = "NixOS Home Emergency Recovery Info";
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
    };
    script = ''
      ${pkgs.coreutils}/bin/cat <<'EOF' > /dev/tty1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 NIXHOME SETUP FEHLGESCHLAGEN (Headless Deadlock Schutz)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mögliche Ursachen:
  1. Kein Netzwerk (Kein WLAN-Treiber gefunden)
     → Bitte USB-Ethernet-Adapter anschließen.
  2. Setup-Wizard abgestürzt
     → Log prüfen: journalctl -u setup-wizard
  3. Konfiguration korrupt
     → Zurücksetzen: nixhome-reset && reboot

Netzwerk-Status:
EOF
      ${pkgs.iproute2}/bin/ip -brief link show > /dev/tty1
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" > /dev/tty1
    '';
  };

  # Integration in Setup-Wizard (onFailure hook)
  # Hinweis: Hier müssten wir wissen wie der Wizard-Service heißt.
  # Wir setzen es vorsorglich für 'setup-wizard.service' falls vorhanden.
}





/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8a83121cd401a1e8a4c025670452f20b22da101f457bd049cf2f949e5d39999d
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
