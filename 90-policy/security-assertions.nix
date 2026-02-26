# 90-policy/security-assertions.nix
# meta:
#   owner: policy
#   status: draft — ASSERTIONS DEAKTIVIERT (Bastelmodus)
#   scope: shared
#   summary: Zentrale Sicherheits-Assertions (einzige Quelle der Wahrheit)
#   specIds: alle SEC-* IDs aus 90-policy/spec-registry.md
#   note: Aktivieren wenn Bastelphase abgeschlossen.
#         server-rules.nix ist deprecated und wird nach Aktivierung dieser Datei gelöscht.
#         Bug-Fix: user-Variable war in alter Version nicht korrekt definiert.

{ config, lib, ... }:
let
  must = assertion: message: { inherit assertion message; };

  # Alle Abhängigkeiten MÜSSEN vor ihrer Verwendung definiert sein
  # source-id: CFG.identity.user
  user = config.my.configs.identity.user;

  # source: 00-core/ports.nix
  sshPort = config.my.ports.ssh;
  websecurePort = config.my.ports.traefikHttps;

  # source: 00-core/secrets.nix
  sharedSecretEnv = config.my.secrets.files.sharedEnv;

  # Abgeleitete Werte
  fwRules = config.networking.firewall.extraInputRules;
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
  sabBinds = config.systemd.services.sabnzbd.bindsTo or [ ];
  hasAuthorizedKeys = (config.users.users.${user}.openssh.authorizedKeys.keys or [ ]) != [ ];
  sshdRestart = config.systemd.services.sshd.serviceConfig.Restart or null;
  sshdWantedBy = config.systemd.services.sshd.wantedBy or [ ];
in
{
  # [BASTELMODUS] Alle Assertions auskommentiert.
  # Einkommentieren sobald Grundkonfiguration stabil ist.
  # Dann server-rules.nix löschen.
  assertions = [
    # Secret contract invariants
    # (must (config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CLOUDFLARE_DNS_API_TOKEN") "[SEC-SECRET-CF-001] cloudflare token variable name must be CLOUDFLARE_DNS_API_TOKEN")
    # (must (config.my.secrets.vars.wgPrivadoPrivateKeyVarName == "WG_PRIVADO_PRIVATE_KEY") "security: WireGuard private key variable name must be WG_PRIVADO_PRIVATE_KEY")

    # SSH hardening invariants
    # (must config.services.openssh.enable "[SEC-SSH-SVC-001] services.openssh.enable must remain true")
    # ... (alle weiteren Assertions auskommentiert lassen)
  ];
}
