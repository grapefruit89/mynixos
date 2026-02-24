{ config, lib, ... }:
let
  must = assertion: message: { inherit assertion message; };

  # source: 00-core/ports.nix
  sshPort = config.my.ports.ssh;
  websecurePort = config.my.ports.traefikHttps;

  # source: 00-core/secrets.nix
  sharedSecretEnv = config.my.secrets.files.sharedEnv;

  # sinks: firewall + service deps
  fwRules = config.networking.firewall.extraInputRules;
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
  sabBinds = config.systemd.services.sabnzbd.bindsTo or [ ];
in
{
  # Server Rules (core guardrails)
  # principle: isomorphic naming + source->sink traceability on every sensitive path.
  assertions = [
    # Secret contract invariants
    (must (config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CF_DNS_API_TOKEN") "security: cloudflare token variable name must be CF_DNS_API_TOKEN")
    (must (config.my.secrets.vars.wgPrivadoPrivateKeyVarName == "WG_PRIVADO_PRIVATE_KEY") "security: WireGuard private key variable name must be WG_PRIVADO_PRIVATE_KEY")

    # SSH hardening invariants
    (must config.services.openssh.enable "security: services.openssh.enable must remain true")
    (must (config.services.openssh.openFirewall == false) "security: services.openssh.openFirewall must remain false")
    (must (config.services.openssh.ports == [ sshPort ]) "security: SSH port must match my.ports.ssh")
    (must (config.services.openssh.settings.PermitRootLogin == "no") "security: root SSH login must stay disabled")
    (must (config.services.openssh.settings.PasswordAuthentication == false) "security: SSH password auth must stay disabled")
    (must (config.services.openssh.settings.KbdInteractiveAuthentication == false) "security: SSH keyboard-interactive auth must stay disabled")
    (must (config.services.openssh.settings.AllowUsers == [ "moritz" ]) "security: SSH allow-list must stay restricted to user moritz")

    # fail2ban invariants
    (must config.services.fail2ban.enable "security: fail2ban must remain enabled")
    (must (config.services.fail2ban.jails.sshd.settings.enabled == true) "security: fail2ban sshd jail must remain enabled")

    # Firewall invariants
    (must config.networking.firewall.enable "security: firewall must remain enabled")
    (must (config.networking.firewall.allowedTCPPorts == [ websecurePort ]) "security: only HTTPS may be globally open")
    (must (config.networking.firewall.allowedUDPPorts == [ ]) "security: no UDP ports may be globally open")
    (must (!(builtins.elem 22 config.networking.firewall.allowedTCPPorts)) "security: TCP port 22 must never be globally open")
    (must (!(builtins.elem 80 config.networking.firewall.allowedTCPPorts)) "security: TCP port 80 must remain closed globally")
    (must (config.networking.firewall.interfaces.tailscale0.allowedTCPPorts == [ sshPort ]) "security: tailscale0 must allow only SSH port from my.ports.ssh")
    (must (lib.hasInfix "tcp dport ${toString sshPort}" fwRules) "security: firewall must explicitly allow SSH from trusted source ranges")
    (must (lib.hasInfix "tcp dport 53" fwRules && lib.hasInfix "udp dport 53" fwRules) "security: firewall must keep DNS 53/tcp+udp restricted via extraInputRules")

    # Tailscale invariants
    (must config.services.tailscale.enable "security: tailscale must remain enabled")
    (must (config.services.tailscale.openFirewall == false) "security: tailscale must not auto-open firewall")

    # Traefik invariants
    (must config.services.traefik.enable "security: Traefik must remain enabled")
    (must (!(config.services.traefik.staticConfigOptions.entryPoints ? web)) "security: Traefik HTTP entrypoint web must stay disabled")
    (must (config.services.traefik.staticConfigOptions.entryPoints.websecure.address == ":${toString websecurePort}") "security: Traefik websecure entrypoint must match my.ports.traefikHttps")
    (must (config.services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.provider == "cloudflare") "security: Traefik ACME DNS provider must stay cloudflare")
    (must (builtins.elem sharedSecretEnv traefikEnv) "security: Traefik must load secrets via my.secrets.files.sharedEnv")

    # Infra / app exposure invariants
    (must (config.services.adguardhome.openFirewall == false) "security: AdGuard must not open firewall ports automatically")
    (must (config.services.homepage-dashboard.openFirewall == false) "security: Homepage Dashboard must not open firewall ports")

    # Media service exposure invariants
    (must (config.services.sonarr.openFirewall == false) "security: Sonarr must not open firewall ports")
    (must (config.services.radarr.openFirewall == false) "security: Radarr must not open firewall ports")
    (must (config.services.readarr.openFirewall == false) "security: Readarr must not open firewall ports")
    (must (config.services.prowlarr.openFirewall == false) "security: Prowlarr must not open firewall ports")
    (must (config.services.sabnzbd.openFirewall == false) "security: SABnzbd must not open firewall ports")
    (must (config.services.jellyfin.openFirewall == false) "security: Jellyfin must not open firewall ports")
    (must (config.services.jellyseerr.openFirewall == false) "security: Jellyseerr must not open firewall ports")

    # VPN + sabnzbd invariants
    (must (config.networking.wg-quick.interfaces ? privado) "security: wg-quick interface 'privado' must be defined")
    (must (config.networking.wg-quick.interfaces.privado.autostart == true) "security: wg-quick privado must autostart")
    (must (builtins.elem "wg-quick-privado.service" sabBinds) "security: sabnzbd must be bound to wg-quick-privado.service")

    # QuickSync invariants for jellyfin
    (must config.hardware.graphics.enable "security: hardware.graphics.enable must stay enabled for jellyfin acceleration")
  ];
}
