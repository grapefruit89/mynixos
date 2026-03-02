/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-010
 *   title: "OliveTin (SRE Exhausted)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018, NIXH-10-INF-002]
 *   downstream: []
 *   status: audited
 * summary: Web-based control panel with Wake-on-Access (Socket Activation).
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/olivetin.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  # source: PORT.olivetin → 00-core/ports.nix  (ERGÄNZEN: olivetin = 10080)
  port        = config.my.ports.olivetin;

  # Script-Pfade absolut und gepinnt (Security: kein $PATH-Hijacking)
  mtlsScript  = "/etc/nixos/00-core/scripts/mtls-manager.sh";
  dnsScript   = "/etc/nixos/00-core/scripts/dns-optimizer.sh";
  cfScript    = "/etc/nixos/00-core/scripts/validate-cloudflare-key.sh";
  moverScript = "/etc/nixos/00-core/scripts/nixhome-mover.sh";
  sopsScript  = "/etc/nixos/00-core/scripts/add-sops-secret.sh";
in
{
  services.olivetin = {
    enable = true;
    path   = with pkgs; [
      bash openssl jq coreutils gnused systemd
      nixos-rebuild nix-output-monitor curl sops
    ];

    settings = {
      ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString port}";
      actions = [
        {
          title = "SOPS: Neues Secret speichern";
          shell = "sudo ${sopsScript} '{{ secret_key }}' '{{ secret_value }}'";
          icon  = "&#128272;";
          arguments = [
            { name = "secret_key";   type = "ascii"; description = "Name in secrets.yaml"; }
            { name = "secret_value"; type = "ascii"; description = "Der geheime Wert"; }
          ];
        }
        {
          title = "System Update";
          # FIX: nixos-rebuild switch über absoluten Pfad (Security: kein PATH-Hijacking)
          shell = "sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch 2>&1 | ${pkgs.nix-output-monitor}/bin/nom";
          icon  = "&#128259;";
        }
        {
          title = "Garbage Collection";
          shell = "sudo ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo ${pkgs.nix}/bin/nix-store --gc";
          icon  = "&#128465;";
        }
        {
          title = "mTLS: Neues Client-Zertifikat";
          shell = "sudo ${mtlsScript} '{{ cert_name }}'";
          icon  = "&#128274;";
          arguments = [
            { name = "cert_name"; type = "ascii"; description = "Name (z.B. handy-moritz)"; }
          ];
        }
        {
          title = "Cloudflare Token prüfen";
          shell = "${cfScript} '{{ cf_token }}'";
          icon  = "&#128273;";
          arguments = [
            { name = "cf_token"; type = "ascii"; description = "Cloudflare API Token"; }
          ];
        }
        {
          title = "Smart Mover: HDD-Tiering";
          shell = "sudo ${moverScript}";
          icon  = "&#128640;";
        }
        {
          title = "Disk Space";
          shell = "${pkgs.duf}/bin/duf";
          icon  = "&#128190;";
        }
        {
          title = "Failed Services";
          shell = "${pkgs.systemd}/bin/systemctl --failed";
          icon  = "&#9888;";
        }
      ];
    };
  };

  # Wake-on-Access via Socket Activation
  systemd.sockets.olivetin = {
    description  = "OliveTin Socket (Wake-on-Access)";
    wantedBy     = [ "sockets.target" ];
    listenStreams = [ (toString port) ];
  };

  systemd.services.olivetin = {
    wantedBy = lib.mkForce [];
    requires = [ "olivetin.socket" ];
    after    = [ "olivetin.socket" ];
  };

  # Sudo-Regeln: Alle Kommandos mit absolutem Pfad gepinnt
  # FIX: "sudo nixos-rebuild" ohne Pfad → Pfad-Hijacking möglich
  security.sudo.extraRules = [
    {
      users    = [ "olivetin" ];
      commands = [
        { command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nix}/bin/nix-env";                options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nix}/bin/nix-store";              options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl";   options = [ "NOPASSWD" ]; }
        { command = mtlsScript;                               options = [ "NOPASSWD" ]; }
        { command = sopsScript;                               options = [ "NOPASSWD" ]; }
        { command = moverScript;                              options = [ "NOPASSWD" ]; }
        { command = "${pkgs.openssl}/bin/openssl";            options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - NMS-ID war NIXH-10-INF-010 (Kollision mit cockpit.nix) → bleibt 010, cockpit korrigiert
 *     - nixos-rebuild in shell-Aktionen mit absolutem Pkgs-Pfad
 *     - PORT.olivetin Registrierungshinweis ergänzt
 *     - Architecture-Header ergänzt
 * ---
 */
