# meta:
#   owner: policy
#   status: active
#   scope: shared
#   summary: Zentrale Sicherheits-Assertions (einzige Quelle der Wahrheit)
#   specIds: [SEC-POL-001, SEC-NET-001, SEC-SSH-001]

{ config, lib, ... }:
let
  # source-id: CFG.identity.bastelmodus
  bastelmodus = config.my.configs.bastelmodus;

  # source-id: CFG.identity.user
  user = config.my.configs.identity.user;

  # Hilfsfunktion für Assertions
  must = assertion: message: { inherit assertion message; };

  # -- Abhängigkeiten für Checks --
  sshPort = config.my.ports.ssh;
  websecurePort = config.my.ports.traefikHttps;
  
  # Check ob Firewall NFTables nutzt
  isNftables = config.networking.nftables.enable;
  
  # Check ob SSH gehärtet ist
  sshSettings = config.services.openssh.settings;
  
  # Check ob Traefik Environment geladen hat
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
  sharedSecretEnv = config.my.secrets.files.sharedEnv;
in
{
  # source-id: CFG.policy.assertions.canonical
  # sink: Systemweite Sicherheitsprüfung
  config = lib.mkIf (!bastelmodus) {
    assertions = [
      # 1. Netzwerk-Sicherheit
      (must (config.networking.firewall.enable == true) "[SEC-NET-001] Firewall muss im Produktionsmodus aktiv sein.")
      (must (isNftables == true) "[SEC-NET-002] NFTables muss als Backend verwendet werden (iptables legacy verboten).")
      
      # 2. SSH-Härtung
      (must (config.services.openssh.enable == true) "[SEC-SSH-001] OpenSSH Dienst muss aktiv sein.")
      (must (sshSettings.PermitRootLogin == "no") "[SEC-SSH-002] Root-Login via SSH muss deaktiviert sein.")
      (must (sshSettings.MaxAuthTries <= 3) "[SEC-SSH-003] MaxAuthTries darf maximal 3 sein.")
      (must (sshSettings.LoginGraceTime <= 30) "[SEC-SSH-004] LoginGraceTime muss <= 30s sein.")
      
      # 3. Traefik & Secrets
      (must (builtins.elem sharedSecretEnv traefikEnv) "[SEC-TRFK-001] Traefik muss das zentrale Secret-Environment laden.")
      
      # 4. Hardware & System
      (must (config.hardware.cpu.intel.updateMicrocode == true) "[SEC-SYS-001] CPU-Microcode Updates müssen für Sicherheit aktiv sein.")
    ];
  };
}
