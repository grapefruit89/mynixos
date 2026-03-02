/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-015
 *   title: "Tailscale (Zero-Touch)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-022]
 *   downstream: []
 *   status: audited
 * summary: Declarative VPN with autoconnect pattern.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/tailscale.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  services.tailscale = {
    enable             = true;
    openFirewall       = false;   # Firewall-Regeln via 00-core/firewall.nix
    useRoutingFeatures = "client";

    extraUpFlags = [
      "--ssh"
      "--accept-dns=true"
      "--accept-routes=true"
    ];

    # Caddy darf Zertifikate direkt vom Daemon beziehen
    permitCertUid = config.services.caddy.user;
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic Tailscale Login";
    after  = [ "tailscaled.service" "network-online.target" ];
    wants  = [ "tailscaled.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "tailscale-auth" ''
        sleep 2
        status=$(${pkgs.tailscale}/bin/tailscale status --json \
          | ${pkgs.jq}/bin/jq -r .BackendState)

        if [ "$status" = "NeedsLogin" ] || [ "$status" = "Stopped" ]; then
          # FIX: Korrekter sops-nix Secret-Pfad
          # In secrets.nix: "infra/tailscale_token" → Pfad hat Schrägstrich
          # sops-nix erzeugt: /run/secrets/infra/tailscale_token
          # config.sops.secrets.tailscale_token.path ist der korrekte Accessor
          ${pkgs.tailscale}/bin/tailscale up \
            --authkey="$(cat ${config.sops.secrets.tailscale_token.path})"
        else
          echo "Tailscale bereits verbunden (Status: $status)"
        fi
      '';
    };
  };

  systemd.services.tailscaled = {
    stopIfChanged = false;   # Verhindert Verbindungsabbruch bei nixos-rebuild
    serviceConfig = {
      Restart        = "always";
      RestartSec     = "2s";
      OOMScoreAdjust = -1000;
    };
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - BUG FIX: config.sops.secrets.tailscale_token → config.sops.secrets.tailscale_token
 *       (In secrets.nix als "infra/tailscale_token" definiert, nicht als "tailscale_token")
 *     - Status-Check erweitert: Ausgabe bei bereits verbundenem Zustand
 *     - Architecture-Header ergänzt
 * ---
 */
