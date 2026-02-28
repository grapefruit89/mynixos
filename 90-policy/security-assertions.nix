/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-90-POL-002
 *   title: "Security Assertions"
 *   layer: 90
 * architecture:
 *   req_refs: [REQ-POL]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:6af32e98a92b8cb85d6eab6579acf60847e3b9e880747bc74c015b72413bd24c
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
