# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: VPN Confinement v1.6 (The Vault)
#   description: Physische Isolation des Media-Stacks in einen Network-Namespace (netns).

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
        # Namespace erstellen
        ${pkgs.iproute2}/bin/ip netns add ${nsName} || true
        ${pkgs.iproute2}/bin/ip netns exec ${nsName} ${pkgs.iproute2}/bin/ip link set lo up

        # VETH-Paar erstellen (Brücke zum Host)
        ${pkgs.iproute2}/bin/ip link add veth-host type veth peer name veth-vault || true
        ${pkgs.iproute2}/bin/ip link set veth-vault netns ${nsName} || true
        
        # IPs zuweisen
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

  # 2. WIREGUARD IM NAMESPACE (Anchored in Host)
  systemd.services.wireguard-vault = {
    description = "WireGuard VPN inside ${nsName}";
    after = [ "netns-${nsName}.service" "sops-install-secrets.service" ];
    requires = [ "netns-${nsName}.service" ];
    wantedBy = [ "multi-user.target" ];
    
    path = with pkgs; [ iproute2 wireguard-tools coreutils gnugrep iputils ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Interface bereinigen falls vorhanden
      ip link del privado 2>/dev/null || true
      ip netns exec ${nsName} ip link del privado 2>/dev/null || true

      # 1. Interface im Host erstellen
      ip link add privado type wireguard
      
      # 2. Konfiguration im Host anwenden
      wg set privado private-key ${wgKey} peer ${wgConfig.publicKey} endpoint ${wgConfig.endpoint} allowed-ips 0.0.0.0/0
      
      # 3. Interface in den Namespace verschieben
      ip link set privado netns ${nsName}
      
      # 4. Interface im Namespace konfigurieren
      ip netns exec ${nsName} ip addr add ${wgConfig.address} dev privado
      ip netns exec ${nsName} ip link set privado up
      
      # 5. DEFAULT ROUTE ÜBER VPN
      ip netns exec ${nsName} ip route add default dev privado || true

      # 6. TRIGGER HANDSHAKE (Ping DNS server of provider)
      ip netns exec ${nsName} ping -c 1 ${lib.head wgConfig.dns} || true
    '';
  };
}
