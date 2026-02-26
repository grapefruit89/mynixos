# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: NFTables-basierter Killswitch für VPN-Dienste

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.vpn-killswitch;
  
  # source: 00-core/configs.nix
  lanCidrs = config.my.configs.network.lanCidrs;
  
  # Liste der Gruppen, die an das VPN gebunden werden sollen
  vpnGroups = [ "sabnzbd" "sonarr" "radarr" "prowlarr" ];
in
{
  config = lib.mkIf cfg.enable {
    # ── NFTABLES KILLSWITCH ──────────────────────────────────────────────────
    networking.nftables.enable = true;
    
    networking.nftables.ruleset = ''
      table inet vpn_killswitch {
        chain base_checks {
          type filter hook output priority 0; policy accept;

          # 1. Erlaube Loopback
          oifname "lo" accept

          # 2. Erlaube Zugriff auf lokales LAN (DNS, Traefik, Inter-Service)
          ip daddr { ${lib.concatStringsSep ", " lanCidrs} } accept

          # 3. VPN-Tunnel (privado) erlauben
          oifname "privado" accept

          # 4. BLOCKIERE alles andere für VPN-Gruppen
          skgid { ${lib.concatStringsSep ", " vpnGroups} } drop
        }
      }
    '';
  };
}
