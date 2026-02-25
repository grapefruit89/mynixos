# meta:
#   owner: policy
#   status: draft — ASSERTIONS DEAKTIVIERT (Bastelmodus)
#   scope: shared
#   summary: Zentrale Sicherheits-Assertions (einzige Quelle der Wahrheit)
#   specIds: siehe 90-policy/spec-registry.md
#   note: Aktivieren wenn Bastelphase abgeschlossen.
#         server-rules.nix ist deprecated und wird nach Aktivierung dieser Datei gelöscht.
#         Bug-Fix vorbereitet: user-Variable ist hier sauber definiert.

{ config, ... }:
let
  must = assertion: message: { inherit assertion message; };
  fwRules = config.networking.firewall.extraInputRules;
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
  sabBinds = config.systemd.services.sabnzbd.bindsTo or [ ];
  hasAuthorizedKeys = (config.users.users.${user}.openssh.authorizedKeys.keys or [ ]) != [ ];
  sshdRestart = config.systemd.services.sshd.serviceConfig.Restart or null;
  sshdWantedBy = config.systemd.services.sshd.wantedBy or [ ];
  sshPort = config.my.ports.ssh;
  websecurePort = config.my.ports.traefikHttps;
  sharedSecretEnv = config.my.secrets.files.sharedEnv;
  user = config.my.identity.user;
in
{
  assertions = [
    # Secret contract invariants
    (must (config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CLOUDFLARE_DNS_API_TOKEN") "[SEC-SECRET-CF-001] cloudflare token variable name must be CLOUDFLARE_DNS_API_TOKEN")
    (must (config.my.secrets.vars.wgPrivadoPrivateKeyVarName == "WG_PRIVADO_PRIVATE_KEY") "security: WireGuard private key variable name must be WG_PRIVADO_PRIVATE_KEY")

    # SSH hardening invariants
    (must config.services.openssh.enable "[SEC-SSH-SVC-001] services.openssh.enable must remain true")
    (must (config.services.openssh.openFirewall == false) "security: services.openssh.openFirewall must remain false")
    (must (config.services.openssh.ports == [ sshPort ]) "[SEC-SSH-PORT-001] SSH port must match my.ports.ssh")
    (must (config.services.openssh.settings.PermitRootLogin == "no") "security: root SSH login must stay disabled")
    (must (config.services.openssh.settings.PermitTTY == true) "[SEC-SSH-TTY-001] SSH TTY must always remain enabled as recovery channel")
    (must (sshdRestart == "always") "[SEC-SSH-SVC-002] sshd service restart policy must stay Restart=always")
    (must (builtins.elem "multi-user.target" sshdWantedBy) "[SEC-SSH-SVC-003] sshd must remain wanted by multi-user.target")
    (must ((config.services.openssh.settings.PasswordAuthentication == false) || (!hasAuthorizedKeys)) "[SEC-SSH-AUTH-001/002] SSH password auth may only be enabled as emergency fallback when no authorized key is present")
    (must ((config.services.openssh.settings.KbdInteractiveAuthentication == false) || (!hasAuthorizedKeys)) "[SEC-SSH-AUTH-001/002] SSH keyboard-interactive auth may only be enabled as emergency fallback when no authorized key is present")
    (must (config.services.openssh.settings.AllowUsers == [ user ]) "security: SSH allow-list must stay restricted to user ${user}")
    # fail2ban invariants
    (must config.services.fail2ban.enable "security: fail2ban must remain enabled")
    (must (config.services.fail2ban.jails.sshd.settings.enabled == true) "security: fail2ban sshd jail must remain enabled")

  # source-id: CFG.ports.ssh
  # sink: Soll-Port für SSH Assertions
  sshPort = config.my.ports.ssh;

    # Firewall invariants
    (must config.networking.firewall.enable "security: firewall must remain enabled")
    (must (config.networking.firewall.allowedTCPPorts == [ websecurePort ]) "[SEC-NET-EDGE-001][SEC-NET-SSH-001] only HTTPS may be globally open; SSH must stay private-network only")
    (must (config.networking.firewall.allowedUDPPorts == [ 5353 ]) "security: only UDP 5353 (mDNS) may be globally open")
    (must (!(builtins.elem 22 config.networking.firewall.allowedTCPPorts)) "security: TCP port 22 must never be globally open")
    (must (!(builtins.elem 80 config.networking.firewall.allowedTCPPorts)) "security: TCP port 80 must remain closed globally")
    (must (config.networking.firewall.interfaces.tailscale0.allowedTCPPorts == [ sshPort ]) "security: tailscale0 must allow only SSH port from my.ports.ssh")
    (must (lib.hasInfix "tcp dport ${toString sshPort}" fwRules) "[SEC-NET-SSH-002] firewall must explicitly allow SSH on my.ports.ssh from private ranges + tailnet")
    (must (lib.hasInfix "tcp dport 53" fwRules && lib.hasInfix "udp dport 53" fwRules) "security: firewall must keep DNS 53/tcp+udp restricted via extraInputRules")

    # Traefik invariants
    (must config.services.traefik.enable "security: Traefik must remain enabled")
    (must (!(config.services.traefik.staticConfigOptions.entryPoints ? web)) "security: Traefik HTTP entrypoint web must stay disabled")
    (must (config.services.traefik.staticConfigOptions.entryPoints.websecure.address == ":${toString websecurePort}") "security: Traefik websecure entrypoint must match my.ports.traefikHttps")
    (must (config.services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.provider == "cloudflare") "security: Traefik ACME DNS provider must stay cloudflare")
    (must (builtins.elem sharedSecretEnv traefikEnv) "security: Traefik must load secrets via my.secrets.files.sharedEnv")

    # Infra / app exposure invariants
    (must (config.services.adguardhome.openFirewall == false) "security: AdGuard must not open firewall ports automatically")
    (must (lib.hasInfix "--host 127.0.0.1" (config.systemd.services.homepage.serviceConfig.ExecStart or "")) "security: Homepage service must bind to 127.0.0.1")

  # source-id: CFG.systemd.sabnzbd.bindsTo
  # sink: VPN-Bindung für sabnzbd Assertions
  sabBinds = config.systemd.services.sabnzbd.bindsTo or [ ];

  # source-id: CFG.users.${user}.authorizedKeys
  # sink: Key-aware SSH Auth Assertion
  hasAuthorizedKeys = (config.users.users.${user}.openssh.authorizedKeys.keys or [ ]) != [ ];

  # source-id: CFG.systemd.sshd.restartPolicy
  # sink: Liveness Assertion für sshd
  sshdRestart = config.systemd.services.sshd.serviceConfig.Restart or null;

  ];
}
