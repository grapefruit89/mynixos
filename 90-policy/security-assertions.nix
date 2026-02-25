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

  # source-id: CFG.identity.user
  # sink: Auflösung des Benutzerobjekts für key-aware SSH Assertions
  user = if config ? my && config.my ? identity && config.my.identity ? user
    then config.my.identity.user
    else "moritz";

  # source-id: CFG.ports.ssh
  # sink: Soll-Port für SSH Assertions
  sshPort = config.my.ports.ssh;

  # source-id: CFG.ports.traefikHttps
  # sink: Soll-Port für Traefik websecure Assertions
  websecurePort = config.my.ports.traefikHttps;

  # source-id: CFG.secrets.sharedEnv
  # sink: Erwartete EnvironmentFile-Quelle für Traefik
  sharedSecretEnv = config.my.secrets.files.sharedEnv;

  # source-id: CFG.firewall.extraInputRules
  # sink: String-Checks für SSH/DNS Allow-Rules
  fwRules = config.networking.firewall.extraInputRules;

  # source-id: CFG.systemd.traefik.environmentFile
  # sink: Vergleich mit sharedSecretEnv
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];

  # source-id: CFG.systemd.sabnzbd.bindsTo
  # sink: VPN-Bindung für sabnzbd Assertions
  sabBinds = config.systemd.services.sabnzbd.bindsTo or [ ];

  # source-id: CFG.users.authorizedKeys
  # sink: Key-aware SSH Auth Assertion
  hasAuthorizedKeys = (config.users.users.${user}.openssh.authorizedKeys.keys or [ ]) != [ ];

  # source-id: CFG.systemd.sshd.restartPolicy
  # sink: Liveness Assertion für sshd
  sshdRestart = config.systemd.services.sshd.serviceConfig.Restart or null;

  # source-id: CFG.systemd.sshd.wantedBy
  # sink: Boot-Target Assertion für sshd
  sshdWantedBy = config.systemd.services.sshd.wantedBy or [ ];
in
{
  # [BASTELMODUS] Alle Assertions absichtlich deaktiviert.
  # Aktivierungsschritt: gewünschte Regeln einkommentieren und server-rules.nix löschen.
  assertions = [
    # (must (config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CLOUDFLARE_DNS_API_TOKEN") "[SEC-SECRET-CF-001] cloudflare token variable name must be CLOUDFLARE_DNS_API_TOKEN")
    # (must config.services.openssh.enable "[SEC-SSH-SVC-001] services.openssh.enable must remain true")
    # (must (config.services.openssh.ports == [ sshPort ]) "[SEC-SSH-PORT-001] SSH port must match my.ports.ssh")
    # (must (config.services.openssh.settings.PermitTTY == true) "[SEC-SSH-TTY-001] SSH TTY must always remain enabled")
    # (must (sshdRestart == "always") "[SEC-SSH-SVC-002] sshd service restart policy must stay Restart=always")
    # (must (builtins.elem "multi-user.target" sshdWantedBy) "[SEC-SSH-SVC-003] sshd must remain wanted by multi-user.target")
    # (must ((config.services.openssh.settings.PasswordAuthentication == false) || (!hasAuthorizedKeys)) "[SEC-SSH-AUTH-001/002] password auth only when no authorized key exists")
    # (must config.networking.firewall.enable "[SEC-NET-EDGE-001] firewall must remain enabled")
    # (must (config.networking.firewall.allowedTCPPorts == [ websecurePort ]) "[SEC-NET-EDGE-001][SEC-NET-SSH-001] only HTTPS may be globally open")
    # (must (lib.hasInfix "tcp dport ${toString sshPort}" fwRules) "[SEC-NET-SSH-002] firewall must explicitly allow SSH from private ranges + tailnet")
    # (must (builtins.elem sharedSecretEnv traefikEnv) "[SEC-TRAEFIK-ENV-001] Traefik must load shared secret env file")
    # (must (builtins.elem "wg-quick-privado.service" sabBinds) "[SEC-VPN-SAB-001] sabnzbd must bind to wg-quick-privado.service")
  ];
}
