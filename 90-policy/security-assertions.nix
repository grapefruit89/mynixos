# meta:
#   owner: policy
#   status: active
#   scope: shared
#   summary: Zentrale Sicherheits-Assertions (einzige Quelle der Wahrheit)
#   specIds: [SEC-POL-001, SEC-NET-001, SEC-SSH-001]

{ config, lib, ... }:
let
  bastelmodus = config.my.configs.bastelmodus;
  user = config.my.configs.identity.user;
  must = assertion: message: { inherit assertion message; };

  sshPort = config.my.ports.ssh;
  sshSettings = config.services.openssh.settings;
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
  sharedSecretEnv = config.my.secrets.files.sharedEnv;
in
{
  config = {
    assertions = [
      # Bastelmodus-Check (Warne wenn er an ist, aber blocke nur wenn nicht gewünscht)
      # Hier könnten wir ein Zeitlimit setzen, aber wir lassen es erst mal informativ
    ] ++ lib.optionals (!bastelmodus) [
      (must (config.networking.firewall.enable == true) "[SEC-NET-001] Firewall muss im Produktionsmodus aktiv sein.")
      (must (config.networking.nftables.enable == true) "[SEC-NET-002] NFTables muss aktiv sein.")
      (must (config.services.openssh.enable == true) "[SEC-SSH-001] OpenSSH Dienst muss aktiv sein.")
      (must (sshSettings.PermitRootLogin == "no") "[SEC-SSH-002] Root-Login via SSH muss deaktiviert sein.")
      (must (sshSettings.MaxAuthTries <= 3) "[SEC-SSH-003] MaxAuthTries darf maximal 3 sein.")
      (must (sshSettings.LoginGraceTime <= 20) "[SEC-SSH-004] LoginGraceTime muss <= 20s sein.")
      (must (builtins.elem sharedSecretEnv traefikEnv) "[SEC-TRFK-001] Traefik muss das zentrale Secret-Environment laden.")
      (must (config.hardware.cpu.intel.updateMicrocode == true) "[SEC-SYS-001] CPU-Microcode Updates müssen aktiv sein.")
    ] ++ [
      {
        assertion = !(config.services.caddy.enable && config.services.traefik.enable);
        message = "[INFRA-001] Caddy UND Traefik gleichzeitig aktiv. Nur ein Proxy darf Port 443 binden. Wähle in registry.nix: my.profiles.networking.reverseProxy";
      }
    ];
  };
}
