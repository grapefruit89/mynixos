/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Global Security Assertions
 * TRACE-ID:     NIXH-POL-001
 * PURPOSE:      Zentrale Sicherheitsprüfungen (Einzige Quelle der Wahrheit).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        90-policy
 * STATUS:       Stable
 */

{ config, lib, ... }:
let
  bastelmodus = config.my.configs.bastelmodus;
  must = assertion: message: { inherit assertion message; };

  sshSettings = config.services.openssh.settings;
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
  sharedSecretEnv = config.my.secrets.files.sharedEnv;
in
{
  config = {
    assertions = [
    ] ++ lib.optionals (!bastelmodus) [
      (must (config.networking.firewall.enable == true) "[SEC-NET-001] Firewall muss im Produktionsmodus aktiv sein.")
      (must (config.networking.nftables.enable == true) "[SEC-NET-002] NFTables muss aktiv sein.")
      (must (config.services.openssh.enable == true) "[SEC-SSH-001] OpenSSH Dienst muss aktiv sein.")
      (must (sshSettings.PermitRootLogin == "no") "[SEC-SSH-002] Root-Login via SSH muss deaktiviert sein.")
      (must (sshSettings.MaxAuthTries <= 3) "[SEC-SSH-003] MaxAuthTries darf maximal 3 sein.")
      (must (sshSettings.LoginGraceTime <= 20) "[SEC-SSH-004] LoginGraceTime muss <= 20s sein.")
      (must (if config.services.traefik.enable then (builtins.elem sharedSecretEnv traefikEnv) else true) "[SEC-TRFK-001] Traefik muss das zentrale Secret-Environment laden.")
      (must (config.hardware.cpu.intel.updateMicrocode == true) "[SEC-SYS-001] CPU-Microcode Updates müssen aktiv sein.")
    ] ++ [
      {
        assertion = !(config.services.caddy.enable && config.services.traefik.enable);
        message = "[INFRA-001] Caddy UND Traefik gleichzeitig aktiv. Nur ein Proxy darf Port 443 binden.";
      }
    ];
  };
}
