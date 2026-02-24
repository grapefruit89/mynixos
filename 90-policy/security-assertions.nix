{ config, lib, ... }:
let
  must = assertion: message: { inherit assertion message; };
  fwRules = config.networking.firewall.extraInputRules;
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
in
{
  assertions = [
    # SSH hardening invariants
    (must config.services.openssh.enable "security: services.openssh.enable must remain true")
    (must (config.services.openssh.openFirewall == false) "security: services.openssh.openFirewall must remain false")
    (must (config.services.openssh.ports == [ 53844 ]) "security: SSH port is fixed to 53844")
    (must (config.services.openssh.settings.PermitRootLogin == "no") "security: root SSH login must stay disabled")
    (must (config.services.openssh.settings.PasswordAuthentication == false) "security: SSH password auth must stay disabled")
    (must (config.services.openssh.settings.KbdInteractiveAuthentication == false) "security: SSH keyboard-interactive auth must stay disabled")
    (must (config.services.openssh.settings.AllowUsers == [ "moritz" ]) "security: SSH allow-list must stay restricted to user moritz")

    # Firewall invariants
    (must config.networking.firewall.enable "security: firewall must remain enabled")
    (must (config.networking.firewall.allowedTCPPorts == [ 80 443 ]) "security: only TCP 80/443 may be globally open")
    (must (config.networking.firewall.allowedUDPPorts == [ ]) "security: no UDP ports may be globally open")
    (must (!(builtins.elem 22 config.networking.firewall.allowedTCPPorts)) "security: TCP port 22 must never be globally open")
    (must (config.networking.firewall.interfaces.tailscale0.allowedTCPPorts == [ 53844 ]) "security: tailscale0 must allow only SSH 53844")
    (must (lib.hasInfix "tcp dport 53844" fwRules) "security: firewall must explicitly allow SSH 53844 from trusted source ranges")
    (must (lib.hasInfix "tcp dport 53" fwRules && lib.hasInfix "udp dport 53" fwRules) "security: firewall must keep DNS 53/tcp+udp restricted via extraInputRules")

    # Traefik invariants
    (must config.services.traefik.enable "security: Traefik must remain enabled")
    (must (config.services.traefik.staticConfigOptions.entryPoints.web.address == ":80") "security: Traefik web entrypoint must stay on :80")
    (must (config.services.traefik.staticConfigOptions.entryPoints.websecure.address == ":443") "security: Traefik websecure entrypoint must stay on :443")
    (must (config.services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.provider == "cloudflare") "security: Traefik ACME DNS provider must stay cloudflare")
    (must (builtins.elem "/etc/secrets/traefik.env" traefikEnv) "security: Traefik must load Cloudflare token via /etc/secrets/traefik.env")

    # AdGuard invariants
    (must config.services.adguardhome.enable "security: AdGuard Home must remain enabled")
    (must (config.services.adguardhome.openFirewall == false) "security: AdGuard must not open firewall ports automatically")
    (must (config.services.adguardhome.host == "0.0.0.0") "security: AdGuard must bind on 0.0.0.0 for LAN/Tailscale DNS")

    # Media service exposure invariants
    (must (config.services.sonarr.openFirewall == false) "security: Sonarr must not open firewall ports")
    (must (config.services.radarr.openFirewall == false) "security: Radarr must not open firewall ports")
    (must (config.services.prowlarr.openFirewall == false) "security: Prowlarr must not open firewall ports")
    (must (config.services.sabnzbd.openFirewall == false) "security: SABnzbd must not open firewall ports")
    (must (config.services.jellyfin.openFirewall == false) "security: Jellyfin must not open firewall ports")
  ];
}
