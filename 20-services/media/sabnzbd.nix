/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-030
 *   title: "Sabnzbd (Nixarr VPN Confinement)"
 *   layer: 20
 * summary: Usenet downloader safely locked inside a network namespace (VPN Confinement).
 * ---
 */
{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "sabnzbd";
      port = config.my.ports.sabnzbd;
      stateOption = "configFile";
      defaultStateDir = "/var/lib/sabnzbd";
      statePathSuffix = "sabnzbd.ini";
      defaultGroup = "media";
    })
  ];
  
  config = {
    # ── NIXARR VPN CONFINEMENT PATTERN ──────────────────────────────────────
    # Wir sperren Sabnzbd physisch in den 'media-vault' Namespace ein.
    # Es hat dadurch absolut keine Verbindung zum unverschlüsselten Host-Netzwerk.
    systemd.services.sabnzbd = lib.mkIf config.services.wireguard.enable {
      requires = [ "wireguard-vault.service" ];
      after = [ "wireguard-vault.service" ];
      
      serviceConfig = {
        # Bindet den Dienst an den Netzwerk-Namespace des VPNs
        NetworkNamespacePath = "/var/run/netns/media-vault";
        # Erlaubt Bindungen an Interfaces in diesem Namespace
        RestrictAddressFamilies = lib.mkForce [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      };
    };

    # Reverse Proxy Integration muss für den Namespace angepasst werden, 
    # falls Caddy nicht im Namespace ist. Für Caddy -> Sabnzbd Kommunikation 
    # nutzen wir die veth IPs (10.200.1.2 im Namespace).
    services.caddy.virtualHosts."sab.${config.my.configs.identity.domain}" = lib.mkIf config.services.wireguard.enable {
      extraConfig = lib.mkForce ''
        import sso_auth
        reverse_proxy 10.200.1.2:${toString config.my.ports.sabnzbd}
      '';
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
