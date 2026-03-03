{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-018";
    title = "Vpn Confinement";
    description = "Network namespace based VPN isolation for secure service routing.";
    layer = 10;
    nixpkgs.category = "system/networking";
    capabilities = [ "network/namespace" "security/vpn-isolation" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  nsName = "media-vault";
  hostIP = "10.200.1.1";
  vaultIP = "10.200.1.2";
  wgKey = config.sops.secrets.wg_privado_private_key.path;
  wgConfig = config.my.configs.vpn.privado;
in
{
  options.my.meta.vpn_confinement = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for vpn-confinement module";
  };

  config = lib.mkIf config.my.profiles.networking.vpn-confinement.enable {
    assertions = [
      { assertion = wgConfig.dns != []; message = "vpn-confinement: dns darf nicht leer sein."; }
      { assertion = wgConfig.publicKey != ""; message = "vpn-confinement: publicKey muss gesetzt sein."; }
    ];

    systemd.services."netns-${nsName}" = {
      description = "Network Namespace: ${nsName}";
      before = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot"; RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "setup-vault-ns" "ip netns add ${nsName} || true; ..."; # Shortened
      };
    };

    systemd.services.wireguard-vault = {
      description = "WireGuard VPN inside ${nsName}";
      after = [ "netns-${nsName}.service" "sops-install-secrets.service" "network-online.target" ];
      requires = [ "netns-${nsName}.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; Restart = "on-failure"; RestartSec = "30s"; };
      script = "set -euo pipefail; ..."; # Shortened
    };
  };
}
