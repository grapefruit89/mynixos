/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-010
 *   title: "OliveTin"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.olivetin;
  mtlsScript = "/etc/nixos/00-core/scripts/mtls-manager.sh";
  dnsScript = "/etc/nixos/00-core/scripts/dns-optimizer.sh";
in
{
  services.olivetin = {
    enable = true;
    # SRE: Tools für die Skripte bereitstellen
    path = with pkgs; [ bash openssl jq coreutils gnused systemd ];
    
    settings = {
      ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString port}";
      actions = [
        {
          title = "System Update (nixos-rebuild switch)";
          shell = "sudo /run/current-system/sw/bin/nixos-rebuild switch";
          icon = "&#128259;"; # 🔄
        }
        {
          title = "Garbage Collection (nclean)";
          shell = "sudo /run/current-system/sw/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo /run/current-system/sw/bin/nix-store --gc";
          icon = "&#128465;"; # 🗑️
        }
        {
          title = "mTLS: Neues Client-Zertifikat erstellen";
          shell = "sudo ${mtlsScript} 'browser-client'";
          icon = "&#128274;"; # 🔐
        }
        {
          title = "mTLS: Download-Link anzeigen";
          shell = "echo 'Zertifikate findest du hier: http://nixhome.local/certs/'";
          icon = "&#128231;"; # 📥
        }
        {
          title = "DNS: Subdomain-Konflikte prüfen & optimieren";
          shell = "${dnsScript}";
          icon = "&#127760;"; # 🌐
        }
        {
          title = "Disk Space Check";
          shell = "/run/current-system/sw/bin/df -h";
          icon = "&#128190;"; # 💾
        }
        {
          title = "Check Failed Services";
          shell = "/run/current-system/sw/bin/systemctl --failed";
          icon = "&#9888;"; # ⚠️
        }
      ];
    };
  };

  # 🛡️ Hardening: OliveTin darf nur bestimmte Befehle via Sudo ohne Passwort
  security.sudo.extraRules = [
    {
      users = [ "olivetin" ];
      commands = [
        { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nix-env"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nix-store"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl"; options = [ "NOPASSWD" ]; }
        { command = "${mtlsScript}"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/openssl"; options = [ "NOPASSWD" ]; }
      ];
        }
      ];
    }
    
    /**
     * ---
 * technical_integrity:
 *   checksum: sha256:e7e0641d688586ccd41b816a5625930c13578de0a97f7ab86fed5ced683c51a7
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-01
 *   complexity_score: 2
 * ---
 */
