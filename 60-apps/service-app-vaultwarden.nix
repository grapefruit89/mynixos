{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-017";
    title = "Vaultwarden (SRE Exhausted)";
    description = "Tightly sandboxed password manager with Wake-on-Access (Socket Activation).";
    layer = 50;
    nixpkgs.category = "services/security";
    capabilities = [ "security/passwords" "security/socket-activation" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.vaultwarden;
in
{
  options.my.meta.vaultwarden = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for vaultwarden module";
  };


  config = lib.mkIf config.my.services.vaultwarden.enable {
    services.vaultwarden = { enable = true; config = { ROCKET_ADDRESS = "127.0.0.1"; ROCKET_PORT = port; SIGNUPS_ALLOWED = false; INVITATIONS_ALLOWED = true; SHOW_PASSWORD_HINT = false; DATABASE_MAX_CONNS = 10; }; environmentFile = config.sops.secrets.vaultwarden_env.path; };
    systemd.sockets.vaultwarden = { description = "Vaultwarden Socket"; wantedBy = [ "sockets.target" ]; listenStreams = [ (toString port) ]; };
    systemd.services.vaultwarden = {
      wantedBy = lib.mkForce [ ]; requires = [ "vaultwarden.socket" ]; after = [ "vaultwarden.socket" ];
      serviceConfig = { ProtectSystem = lib.mkForce "strict"; ReadWritePaths = [ "/var/lib/vaultwarden" ]; MemoryDenyWriteExecute = lib.mkForce true; RestrictAddressFamilies = lib.mkForce [ "AF_INET" "AF_UNIX" ]; SystemCallFilter = lib.mkForce [ "@system-service" "~@privileged" "~@resources" ]; NoNewPrivileges = lib.mkForce true; PrivateDevices = lib.mkForce true; PrivateTmp = lib.mkForce true; OOMScoreAdjust = 200; };
    };
  };
}
