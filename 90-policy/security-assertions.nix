/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-90-SEC-POL-002
 *   title: "Security Assertions"
 *   layer: 90
 * architecture:
 *   req_refs: [REQ-POL]
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  bastelmodus = config.my.configs.bastelmodus;
  must = assertion: message: { inherit assertion message; };

  sshSettings = config.services.openssh.settings;
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
      (must (config.hardware.cpu.intel.updateMicrocode == true) "[SEC-SYS-001] CPU-Microcode Updates müssen aktiv sein.")
    ];
  };
}

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:c48bbad9c1486c73a636d575b6c013e23f590c4d7880feb99856c12d52151273
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
