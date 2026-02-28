/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Vpn Confinement
 * TRACE-ID:     NIXH-INF-013
 * REQ-REF:      REQ-INF
 * LAYER:        20
 * STATUS:       Stable
 * INTEGRITY:    SHA256:f1f5787a3ccd384af9f8013d5c52b40a826a817ccd599822c049bdcfbfefb8e9
 */

{ config, lib, pkgs, ... }:
let
  nsName = "media-vault";
  hostIP = "10.200.1.1";
  vaultIP = "10.200.1.2";
  
  wgKey = config.sops.secrets.wg_privado_private_key.path;
  wgConfig = config.my.configs.vpn.privado;
in
{
  # 1. NAMESPACE INITIALISIERUNG
  systemd.services."netns-${nsName}" = {
    description = "Network Namespace: ${nsName}";
    before = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "setup-vault-ns" ''
        set -euo pipefail
        ${pkgs.iproute2}/bin/ip netns add ${nsName} || true
        ${pkgs.iproute2}/bin/ip netns exec ${nsName} ${pkgs.iproute2}/bin/ip link set lo up
        ${pkgs.iproute2}/bin/ip link add veth-host type veth peer name veth-vault || true
        ${pkgs.iproute2}/bin/ip link set veth-vault netns ${nsName} || true
        ${pkgs.iproute2}/bin/ip addr add ${hostIP}/24 dev veth-host || true
        ${pkgs.iproute2}/bin/ip link set veth-host up
        ${pkgs.iproute2}/bin/ip netns exec ${nsName} ${pkgs.iproute2}/bin/ip addr add ${vaultIP}/24 dev veth-vault || true
        ${pkgs.iproute2}/bin/ip netns exec ${nsName} ${pkgs.iproute2}/bin/ip link set veth-vault up
      '';
      ExecStop = pkgs.writeShellScript "cleanup-vault-ns" ''
        ${pkgs.iproute2}/bin/ip link del veth-host || true
        ${pkgs.iproute2}/bin/ip netns del ${nsName} || true
      '';
    };
  };

  # 2. WIREGUARD IM NAMESPACE
  systemd.services.wireguard-vault = {
    description = "WireGuard VPN inside ${nsName}";
    after = [ 
      "netns-${nsName}.service" 
      "sops-install-secrets.service"
      "network-online.target"
    ];
    requires = [ 
      "netns-${nsName}.service" 
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iproute2 wireguard-tools coreutils gnugrep iputils ];
    
    serviceConfig = { 
      Type = "oneshot"; 
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "30s";
    };

    script = ''
      set -euo pipefail
      
      ip link del privado 2>/dev/null || true
      ip netns exec ${nsName} ip link del privado 2>/dev/null || true
      
      ip link add privado type wireguard
      
      wg set privado \
        private-key ${wgKey} \
        peer ${wgConfig.publicKey} \
        endpoint ${wgConfig.endpoint} \
        allowed-ips 0.0.0.0/0 \
        persistent-keepalive 25
      
      ip link set privado netns ${nsName}
      ip netns exec ${nsName} ip addr add ${wgConfig.address} dev privado
      ip netns exec ${nsName} ip link set privado up
      ip netns exec ${nsName} ip route add default dev privado || true
      
      echo "Performing VPN Health Check..."
      timeout 10 ip netns exec ${nsName} \
        ping -c 3 -W 3 ${lib.head wgConfig.dns} \
        || { echo "VPN connection failed!"; exit 1; }
      
      echo "VPN OK - Namespace ${nsName} isolated"
    '';
  };
}
