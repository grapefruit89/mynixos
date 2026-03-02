/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-010
 *   title: "OliveTin (SRE Control Panel)"
 *   layer: 10
 * summary: Web-based control panel for safe system operations with interactive SRE workflows.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/olivetin.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.olivetin;
  mtlsScript = "/etc/nixos/00-core/scripts/mtls-manager.sh";
  dnsScript = "/etc/nixos/00-core/scripts/dns-optimizer.sh";
  cfScript = "/etc/nixos/00-core/scripts/validate-cloudflare-key.sh";
  moverScript = "/etc/nixos/00-core/scripts/nixhome-mover.sh";
  sopsScript = "/etc/nixos/00-core/scripts/add-sops-secret.sh";
in
{
  # 🚀 OLIVETIN EXHAUSTION
  services.olivetin = {
    enable = true;
    # SRE: Pakete für die Shell-Aktionen bereitstellen
    path = with pkgs; [ 
      bash openssl jq coreutils gnused systemd 
      nixos-rebuild nix-output-monitor curl sops
    ];
    
    settings = {
      ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString port}";
      actions = [
        {
          title = "SOPS: Neues Secret speichern";
          shell = "sudo ${sopsScript} '{{ secret_key }}' '{{ secret_value }}'";
          icon = "&#128272;";
          arguments = [
            { name = "secret_key"; type = "ascii"; description = "Name in secrets.yaml (z.B. neu_api_key)"; }
            { name = "secret_value"; type = "ascii"; description = "Der geheime Wert"; }
          ];
        }
        {
          title = "System Update (nixos-rebuild switch)";
          shell = "sudo nixos-rebuild switch";
          icon = "&#128259;"; 
        }
        {
          title = "Garbage Collection (nclean)";
          shell = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
          icon = "&#128465;"; 
        }
        {
          title = "mTLS: Neues Client-Zertifikat erstellen";
          shell = "sudo ${mtlsScript} '{{ cert_name }}'";
          icon = "&#128274;"; 
          arguments = [
            {
              name = "cert_name";
              type = "ascii";
              description = "Name für das Zertifikat (z.B. handy-moritz)";
            }
          ];
        }
        {
          title = "API Key: Cloudflare Token prüfen";
          shell = "${cfScript} '{{ cf_token }}'";
          icon = "&#128273;";
          arguments = [
            {
              name = "cf_token";
              type = "ascii";
              description = "Cloudflare API Token einfügen (wird direkt gegen die API geprüft)";
            }
          ];
        }
        {
          title = "Smart Mover: Status & HDD-Tiering prüfen";
          shell = "sudo ${moverScript} --status";
          icon = "&#128640;"; 
        }
        {
          title = "mTLS: Download-Link anzeigen";
          shell = "echo 'Zertifikate findest du hier: http://nixhome.local/certs/'";
          icon = "&#128231;"; 
        }
        {
          title = "DNS: Subdomain-Konflikte prüfen & optimieren";
          shell = "${dnsScript}";
          icon = "&#127760;"; 
        }
        {
          title = "Disk Space Check";
          shell = "df -h";
          icon = "&#128190;"; 
        }
        {
          title = "Check Failed Services";
          shell = "systemctl --failed";
          icon = "&#9888;"; 
        }
      ];
    };
  };

  # 🛡️ SRE HARDENING: OliveTin darf nur bestimmte Befehle via Sudo ohne Passwort
  security.sudo.extraRules = [
    {
      users = [ "olivetin" ];
      commands = [
        { command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nix}/bin/nix-env"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nix}/bin/nix-store"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl"; options = [ "NOPASSWD" ]; }
        { command = "${mtlsScript}"; options = [ "NOPASSWD" ]; }
        { command = "${sopsScript}"; options = [ "NOPASSWD" ]; }
        { command = "${moverScript}"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.openssl}/bin/openssl"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
