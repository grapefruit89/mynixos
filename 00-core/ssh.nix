{ lib, config, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-025";
    title = "SSH (SRE Expert Edition)";
    description = "Hardened SSH daemon with connection protection and modern crypto.";
    layer = 00;
    nixpkgs.category = "system/networking";
    capabilities = [ "security/ssh" "network/hardening" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  sshPort = config.my.ports.ssh;
  user = config.my.configs.identity.user;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  matchCidrs = lib.concatStringsSep "," (lanCidrs ++ tailnetCidrs);
in
{
  options.my.meta.ssh = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for ssh module";
  };

  config = {
    services.openssh = {
      enable = true;
      openFirewall = false;
      ports = lib.mkForce [ 22 sshPort ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = [ "${user}" ];
        LogLevel = "VERBOSE";
        LoginGraceTime = 20;
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" "sntrup761x25519-sha512@openssh.com" ];
        Ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
      };
      extraConfig = "Match Address 127.0.0.1,::1,${matchCidrs}\n  X11Forwarding yes\n  AllowTcpForwarding yes\n  GatewayPorts yes";
    };

    systemd.services.sshd = {
      stopIfChanged = false;
      serviceConfig = {
        Restart = "always"; RestartSec = "5s";
        ProtectProc = "invisible"; ProcSubset = "pid"; PrivateTmp = true; ProtectSystem = "strict"; ProtectHome = "read-only";
        CapabilityBoundingSet = [ "CAP_CHOWN" "CAP_SETUID" "CAP_SETGID" "CAP_SYS_CHROOT" "CAP_AUDIT_WRITE" "CAP_NET_BIND_SERVICE" ];
      };
    };
  };
}
