/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-015
 *   title: "Tailscale (Zero-Touch)"
 *   layer: 10
 * summary: Declarative VPN with autoconnect pattern.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/tailscale.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "client";
    
    extraUpFlags = [
      "--ssh"
      "--accept-dns=true"
      "--accept-routes=true"
    ];

    # Caddy darf Zertifikate direkt vom Daemon beziehen
    permitCertUid = config.services.caddy.user;
  };

  # ── TAILSCALE AUTOCONNECT PATTERN ─────────────────────────────────────────
  # Dieser Dienst sorgt dafür, dass sich der Server bei einer Neuinstallation
  # völlig automatisch im Tailnet anmeldet, ohne manuelles 'tailscale up'.
  systemd.services.tailscale-autoconnect = {
    description = "Automatic Tailscale Login";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "tailscaled.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      # Nutzt das sops-Geheimnis
      ExecStart = pkgs.writeShellScript "tailscale-auth" ''
        # Warte kurz, bis der Daemon wirklich bereit ist
        sleep 2
        # Prüfe Status
        status=$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -r .BackendState)
        if [ "$status" = "NeedsLogin" ] || [ "$status" = "Stopped" ]; then
          ${pkgs.tailscale}/bin/tailscale up --authkey="$(cat ${config.sops.secrets.tailscale_token.path})"
        fi
      '';
    };
  };

  # ── REBUILD PROTECTION ───────────────────────────────────────────────────
  systemd.services.tailscaled = {
    # Verhindert, dass die Verbindung bei einem nixos-rebuild abreißt
    stopIfChanged = false;
    
    serviceConfig = {
      Restart = "always";
      RestartSec = "2s";
      OOMScoreAdjust = -1000;
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
