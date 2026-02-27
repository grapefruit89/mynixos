# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: zentrale Konfigurationswerte (Single Source of Truth)

{ lib, config, ... }:
{
  imports = [ ../10-infrastructure/vpn-live-config.nix ];

  options.my.configs = {
    # source-id: CFG.identity.bastelmodus
    bastelmodus = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Aktiviert den Bastelmodus: Firewall aus, passwortloses Sudo, keine Security-Assertions.";
    };

    identity = {
      # source-id: CFG.identity.domain
      domain = lib.mkOption {
        type = lib.types.str;
        default = "m7c5.de";
        description = "Primäre Domain des Homelab-Stacks.";
      };

      # source-id: CFG.identity.email
      email = lib.mkOption {
        type = lib.types.str;
        default = "moritzbaumeister@gmail.com";
        description = "Admin/ACME Kontaktadresse.";
      };

      # source-id: CFG.identity.user
      user = lib.mkOption {
        type = lib.types.str;
        default = "moritz";
        description = "Primärer Administrationsbenutzer.";
      };

      # source-id: CFG.identity.host
      host = lib.mkOption {
        type = lib.types.str;
        default = "q958";
        description = "Hostname des Servers.";
      };
    };

    hardware = {
      # source-id: CFG.hardware.intelGpu
      intelGpu = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Aktiviert Intel GPU-Optimierungen (GuC/HuC, Treiber).";
      };

      # source-id: CFG.hardware.cpuMicrocode
      updateMicrocode = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Aktiviert CPU-Microcode-Updates.";
      };
    };

    network = {
      # source-id: CFG.network.lanCidrs
      lanCidrs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
        description = "Private LAN-Netze (RFC1918) für interne Freigaben.";
      };

      # source-id: CFG.network.tailnetCidrs
      tailnetCidrs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "100.64.0.0/10" ];
        description = "Tailscale CGNAT-Bereich für Tailnet-Zugriffe.";
      };

      # source-id: CFG.network.dnsDoH
      dnsDoH = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "https://one.one.one.one/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
        description = "Upstream DoH Resolver.";
      };

      # source-id: CFG.network.dnsBootstrap
      dnsBootstrap = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1" "9.9.9.9" ];
        description = "Bootstrap DNS Server für DoH Auflösung.";
      };

      # source-id: CFG.network.dnsNamed
      dnsNamed = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1" "9.9.9.9" ];
        description = "Standard DNS Resolver.";
      };

      # source-id: CFG.network.dnsFallback
      dnsFallback = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1" "9.9.9.9" ];
        description = "Fallback DNS Resolver.";
      };

      # source-id: CFG.network.acmeResolvers
      acmeResolvers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1:53" "9.9.9.9:53" ];
        description = "DNS Resolver für ACME-DNS-Challenge.";
      };
    };

    server = {
      # source-id: CFG.server.lanIP
      lanIP = lib.mkOption {
        type = lib.types.str;
        default = "192.168.2.73";
        description = "Primäre LAN-IP des Servers.";
        example = "192.168.1.100";
      };

      # source-id: CFG.server.tailscaleIP
      tailscaleIP = lib.mkOption {
        type = lib.types.str;
        default = "100.113.29.82";
        description = "Tailscale-IP des Servers.";
        example = "100.x.y.z";
      };
    };

    vpn = {
      privado = {
        # source-id: CFG.vpn.privado.address
        address = lib.mkOption {
          type = lib.types.str;
          default = "100.64.4.147/32";
          description = "WireGuard Interface-IP für Privado VPN.";
        };

        # source-id: CFG.vpn.privado.dns
        dns = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "198.18.0.1" "198.18.0.2" ];
          description = "DNS-Server des Privado VPN.";
        };

        # source-id: CFG.vpn.privado.endpoint
        endpoint = lib.mkOption {
          type = lib.types.str;
          default = "91.148.237.21:51820";
          description = "WireGuard Peer-Endpoint für Privado VPN.";
        };

        # source-id: CFG.vpn.privado.publicKey
        publicKey = lib.mkOption {
          type = lib.types.str;
          default = "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
          description = "WireGuard Peer-PublicKey des Privado-Servers.";
        };
      };
    };
  };

  config = {
    # source-id: CFG.identity.host
    # sink: system hostname
    networking.hostName = config.my.configs.identity.host;

    assertions = [
      {
        # source-id: CFG.server.lanIP
        # sink: verhindert leeren LAN-IP Wert
        assertion = config.my.configs.server.lanIP != "";
        message = "CFG.server.lanIP muss gesetzt sein (z.B. '192.168.2.73')";
      }
      {
        # source-id: CFG.server.tailscaleIP
        # sink: verhindert leeren Tailscale-IP Wert
        assertion = config.my.configs.server.tailscaleIP != "";
        message = "CFG.server.tailscaleIP muss gesetzt sein (z.B. '100.x.y.z')";
      }
    ];
  };
}

