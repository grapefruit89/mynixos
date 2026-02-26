# Configs Centralization Report (Draft)

Scope: /etc/nixos (excluding docs/**, hardware-configuration.nix, *.md, tailscale-policy*.hujson, wireguard-privado.conf.example)
Purpose: identify hardcoded values for potential centralization in 00-core/configs.nix.

## Domains
/etc/nixos/20-services/media/media-stack.nix:4:    defaults.domain = "m7c5.de";
/etc/nixos/20-services/apps/vaultwarden.nix:4:  domain = "m7c5.de";
/etc/nixos/20-services/apps/n8n.nix:4:  domain = "m7c5.de";
/etc/nixos/10-infrastructure/pocket-id.nix:3:  domain = "m7c5.de";
/etc/nixos/10-infrastructure/homepage.nix:3:  domain = "m7c5.de";
/etc/nixos/10-infrastructure/traefik-core.nix:3:  domain = "m7c5.de";
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:3:  domain = "m7c5.de";
/etc/nixos/10-infrastructure/homepage.nix:9:  localeProfile = config.my.locale.profile;
/etc/nixos/00-core/dummy.nix:29:      default = "example.local";
/etc/nixos/00-core/locale.nix:36:  profile = config.my.locale.profile;
/etc/nixos/00-core/locale.nix:43:  options.my.locale.profile = lib.mkOption {
/etc/nixos/00-core/locale.nix:51:      (must (builtins.elem profile allowed) "locale: my.locale.profile must be one of: ${lib.concatStringsSep ", " allowed}")
/etc/nixos/00-core/locale.nix:56:    i18n.defaultLocale = cfg.locale;

## Emails
/etc/nixos/10-infrastructure/pocket-id.nix:25:      #     email = "moritzbaumeister@gmail.com";
/etc/nixos/10-infrastructure/traefik-core.nix:60:        email = "moritzbaumeister@gmail.com";
/etc/nixos/00-core/configs-plan.nix:34:#   - value: "moritzbaumeister@gmail.com"

## IPs
/etc/nixos/20-services/media/arr-wire.nix:46:        SONARR_URL="''${SONARR_URL:-http://127.0.0.1:${toString config.my.ports.sonarr}}"
/etc/nixos/20-services/media/arr-wire.nix:47:        RADARR_URL="''${RADARR_URL:-http://127.0.0.1:${toString config.my.ports.radarr}}"
/etc/nixos/20-services/media/arr-wire.nix:48:        PROWLARR_URL="''${PROWLARR_URL:-http://127.0.0.1:${toString config.my.ports.prowlarr}}"
/etc/nixos/20-services/media/arr-wire.nix:49:        SABNZBD_URL="''${SABNZBD_URL:-http://127.0.0.1:${toString config.my.ports.sabnzbd}}"
/etc/nixos/20-services/media/_lib.nix:98:        { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/monica.nix:24:          addr = "127.0.0.1";
/etc/nixos/20-services/apps/monica.nix:53:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/vaultwarden.nix:10:      ROCKET_ADDRESS = "127.0.0.1";
/etc/nixos/20-services/apps/vaultwarden.nix:25:        url = "http://127.0.0.1:${toString config.my.ports.vaultwarden}";
/etc/nixos/20-services/apps/miniflux.nix:11:      LISTEN_ADDR = "127.0.0.1:${toString port}";
/etc/nixos/20-services/apps/miniflux.nix:25:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/scrutiny.nix:22:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/paperless.nix:10:    address = "127.0.0.1";
/etc/nixos/20-services/apps/paperless.nix:23:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/readeck.nix:19:        host = "127.0.0.1";
/etc/nixos/20-services/apps/readeck.nix:34:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/audiobookshelf.nix:19:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/n8n.nix:11:      N8N_HOST = "127.0.0.1";
/etc/nixos/20-services/apps/n8n.nix:25:      url = "http://127.0.0.1:${toString config.my.ports.n8n}";
/etc/nixos/90-policy/security-assertions.nix:56:    (must (lib.hasInfix "--host 127.0.0.1" (config.systemd.services.homepage.serviceConfig.ExecStart or "")) "security: Homepage service must bind to 127.0.0.1")
/etc/nixos/10-infrastructure/cloudflared-tunnel.nix:5:  traefikUrl = "https://127.0.0.1:${toString config.my.ports.traefikHttps}";
/etc/nixos/10-infrastructure/pocket-id.nix:46:        url = "http://127.0.0.1:3000";
/etc/nixos/10-infrastructure/adguardhome.nix:7:    host = "0.0.0.0";
/etc/nixos/10-infrastructure/adguardhome.nix:14:        # Avoid conflict with systemd-resolved (127.0.0.53/54:53) while keeping
/etc/nixos/10-infrastructure/adguardhome.nix:17:          "127.0.0.1"
/etc/nixos/10-infrastructure/adguardhome.nix:18:          "192.168.2.73"
/etc/nixos/10-infrastructure/adguardhome.nix:19:          "100.113.29.82"
/etc/nixos/10-infrastructure/adguardhome.nix:25:        bootstrap_dns = [ "1.1.1.1" "9.9.9.9" ];
/etc/nixos/10-infrastructure/ddns-updater.nix:27:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/10-infrastructure/homepage.nix:60:        url = "http://127.0.0.1:${toString homepagePort}";
/etc/nixos/10-infrastructure/traefik-core.nix:5:    "127.0.0.1/32"
/etc/nixos/10-infrastructure/traefik-core.nix:6:    "192.168.0.0/16"
/etc/nixos/10-infrastructure/traefik-core.nix:7:    "172.16.0.0/12"
/etc/nixos/10-infrastructure/traefik-core.nix:8:    "10.0.0.0/8"
/etc/nixos/10-infrastructure/traefik-core.nix:9:    "173.245.48.0/20"
/etc/nixos/10-infrastructure/traefik-core.nix:10:    "103.21.244.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:11:    "103.22.200.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:12:    "103.31.4.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:13:    "141.101.64.0/18"
/etc/nixos/10-infrastructure/traefik-core.nix:14:    "108.162.192.0/18"
/etc/nixos/10-infrastructure/traefik-core.nix:15:    "190.93.240.0/20"
/etc/nixos/10-infrastructure/traefik-core.nix:16:    "188.114.96.0/20"
/etc/nixos/10-infrastructure/traefik-core.nix:17:    "197.234.240.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:18:    "198.41.128.0/17"
/etc/nixos/10-infrastructure/traefik-core.nix:19:    "162.158.0.0/15"
/etc/nixos/10-infrastructure/traefik-core.nix:20:    "104.16.0.0/13"
/etc/nixos/10-infrastructure/traefik-core.nix:21:    "104.24.0.0/14"
/etc/nixos/10-infrastructure/traefik-core.nix:22:    "172.64.0.0/13"
/etc/nixos/10-infrastructure/traefik-core.nix:23:    "131.0.72.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:65:          resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
/etc/nixos/10-infrastructure/traefik-core.nix:103:          address = "http://127.0.0.1:3000";
/etc/nixos/10-infrastructure/traefik-core.nix:126:          "127.0.0.1/32"
/etc/nixos/10-infrastructure/traefik-core.nix:127:          "192.168.0.0/16"
/etc/nixos/10-infrastructure/traefik-core.nix:128:          "172.16.0.0/12"
/etc/nixos/10-infrastructure/traefik-core.nix:129:          "10.0.0.0/8"
/etc/nixos/10-infrastructure/traefik-core.nix:130:          "100.64.0.0/10"
/etc/nixos/10-infrastructure/traefik-core.nix:161:          allowlist.ip = [ "127.0.0.1" "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "100.64.0.0/10" ];
/etc/nixos/10-infrastructure/wireguard-vpn.nix:49:Address = 100.64.4.147/32
/etc/nixos/10-infrastructure/wireguard-vpn.nix:50:DNS = 198.18.0.1,198.18.0.2
/etc/nixos/10-infrastructure/wireguard-vpn.nix:54:AllowedIPs = 0.0.0.0/0
/etc/nixos/10-infrastructure/wireguard-vpn.nix:55:Endpoint = 91.148.237.21:51820
/etc/nixos/10-infrastructure/valkey.nix:4:  # sink:   local valkey on 127.0.0.1:6379 for internal apps
/etc/nixos/10-infrastructure/valkey.nix:11:      bind = "127.0.0.1";
/etc/nixos/00-core/locale.nix:64:      "127.0.0.1"
/etc/nixos/00-core/locale.nix:65:      "1.1.1.1#one.one.one.one"
/etc/nixos/00-core/locale.nix:66:      "9.9.9.9#dns.quad9.net"
/etc/nixos/00-core/locale.nix:75:        "1.1.1.1#one.one.one.one"
/etc/nixos/00-core/locale.nix:76:        "1.0.0.1#one.one.one.one"
/etc/nixos/00-core/locale.nix:77:        "9.9.9.9#dns.quad9.net"
/etc/nixos/00-core/locale.nix:78:        "149.112.112.112#dns.quad9.net"
/etc/nixos/00-core/ssh.nix:35:      Match Address 127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10
/etc/nixos/00-core/server-rules.nix:74:    (must (lib.hasInfix "--host 127.0.0.1" (config.systemd.services.homepage.serviceConfig.ExecStart or "")) "security: Homepage service must bind to 127.0.0.1")
/etc/nixos/00-core/fail2ban.nix:19:      "127.0.0.1/8"
/etc/nixos/00-core/fail2ban.nix:21:      "10.0.0.0/8"
/etc/nixos/00-core/fail2ban.nix:22:      "172.16.0.0/12"
/etc/nixos/00-core/fail2ban.nix:23:      "192.168.0.0/16"
/etc/nixos/00-core/fail2ban.nix:24:      "100.64.0.0/10"
/etc/nixos/00-core/secrets.nix:79:      SONARR_URL=http://127.0.0.1:8989
/etc/nixos/00-core/secrets.nix:80:      RADARR_URL=http://127.0.0.1:7878
/etc/nixos/00-core/secrets.nix:81:      PROWLARR_URL=http://127.0.0.1:9696
/etc/nixos/00-core/secrets.nix:82:      SABNZBD_URL=http://127.0.0.1:8080
/etc/nixos/00-core/firewall.nix:11:  rfc1918 = "10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16";
/etc/nixos/00-core/firewall.nix:12:  tailnet = "100.64.0.0/10";
/etc/nixos/00-core/firewall.nix:46:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:47:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:48:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:49:      /run/current-system/sw/bin/iptables -A nixos-fw -s 100.64.0.0/10 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:51:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:52:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:53:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:54:      /run/current-system/sw/bin/iptables -A nixos-fw -s 100.64.0.0/10 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:56:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:57:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:58:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:59:      /run/current-system/sw/bin/iptables -A nixos-fw -s 100.64.0.0/10 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:61:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p udp --dport 5353 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:62:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p udp --dport 5353 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:63:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p udp --dport 5353 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:67:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:68:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:69:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:70:      /run/current-system/sw/bin/iptables -D nixos-fw -s 100.64.0.0/10 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:72:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:73:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:74:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:75:      /run/current-system/sw/bin/iptables -D nixos-fw -s 100.64.0.0/10 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:77:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:78:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:79:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:80:      /run/current-system/sw/bin/iptables -D nixos-fw -s 100.64.0.0/10 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:82:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p udp --dport 5353 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:83:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p udp --dport 5353 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:84:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p udp --dport 5353 -j nixos-fw-accept || true

## CIDRs
/etc/nixos/10-infrastructure/adguardhome.nix:14:        # Avoid conflict with systemd-resolved (127.0.0.53/54:53) while keeping
/etc/nixos/10-infrastructure/traefik-core.nix:5:    "127.0.0.1/32"
/etc/nixos/10-infrastructure/traefik-core.nix:6:    "192.168.0.0/16"
/etc/nixos/10-infrastructure/traefik-core.nix:7:    "172.16.0.0/12"
/etc/nixos/10-infrastructure/traefik-core.nix:8:    "10.0.0.0/8"
/etc/nixos/10-infrastructure/traefik-core.nix:9:    "173.245.48.0/20"
/etc/nixos/10-infrastructure/traefik-core.nix:10:    "103.21.244.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:11:    "103.22.200.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:12:    "103.31.4.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:13:    "141.101.64.0/18"
/etc/nixos/10-infrastructure/traefik-core.nix:14:    "108.162.192.0/18"
/etc/nixos/10-infrastructure/traefik-core.nix:15:    "190.93.240.0/20"
/etc/nixos/10-infrastructure/traefik-core.nix:16:    "188.114.96.0/20"
/etc/nixos/10-infrastructure/traefik-core.nix:17:    "197.234.240.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:18:    "198.41.128.0/17"
/etc/nixos/10-infrastructure/traefik-core.nix:19:    "162.158.0.0/15"
/etc/nixos/10-infrastructure/traefik-core.nix:20:    "104.16.0.0/13"
/etc/nixos/10-infrastructure/traefik-core.nix:21:    "104.24.0.0/14"
/etc/nixos/10-infrastructure/traefik-core.nix:22:    "172.64.0.0/13"
/etc/nixos/10-infrastructure/traefik-core.nix:23:    "131.0.72.0/22"
/etc/nixos/10-infrastructure/traefik-core.nix:126:          "127.0.0.1/32"
/etc/nixos/10-infrastructure/traefik-core.nix:127:          "192.168.0.0/16"
/etc/nixos/10-infrastructure/traefik-core.nix:128:          "172.16.0.0/12"
/etc/nixos/10-infrastructure/traefik-core.nix:129:          "10.0.0.0/8"
/etc/nixos/10-infrastructure/traefik-core.nix:130:          "100.64.0.0/10"
/etc/nixos/10-infrastructure/traefik-core.nix:161:          allowlist.ip = [ "127.0.0.1" "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "100.64.0.0/10" ];
/etc/nixos/10-infrastructure/wireguard-vpn.nix:49:Address = 100.64.4.147/32
/etc/nixos/10-infrastructure/wireguard-vpn.nix:54:AllowedIPs = 0.0.0.0/0
/etc/nixos/00-core/ssh.nix:35:      Match Address 127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10
/etc/nixos/00-core/firewall.nix:11:  rfc1918 = "10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16";
/etc/nixos/00-core/firewall.nix:12:  tailnet = "100.64.0.0/10";
/etc/nixos/00-core/firewall.nix:46:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:47:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:48:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:49:      /run/current-system/sw/bin/iptables -A nixos-fw -s 100.64.0.0/10 -p tcp --dport ${toString sshPort} -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:51:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:52:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:53:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:54:      /run/current-system/sw/bin/iptables -A nixos-fw -s 100.64.0.0/10 -p tcp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:56:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:57:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:58:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:59:      /run/current-system/sw/bin/iptables -A nixos-fw -s 100.64.0.0/10 -p udp --dport 53 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:61:      /run/current-system/sw/bin/iptables -A nixos-fw -s 10.0.0.0/8 -p udp --dport 5353 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:62:      /run/current-system/sw/bin/iptables -A nixos-fw -s 172.16.0.0/12 -p udp --dport 5353 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:63:      /run/current-system/sw/bin/iptables -A nixos-fw -s 192.168.0.0/16 -p udp --dport 5353 -j nixos-fw-accept
/etc/nixos/00-core/firewall.nix:67:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:68:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:69:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:70:      /run/current-system/sw/bin/iptables -D nixos-fw -s 100.64.0.0/10 -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:72:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:73:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:74:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:75:      /run/current-system/sw/bin/iptables -D nixos-fw -s 100.64.0.0/10 -p tcp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:77:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:78:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:79:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:80:      /run/current-system/sw/bin/iptables -D nixos-fw -s 100.64.0.0/10 -p udp --dport 53 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:82:      /run/current-system/sw/bin/iptables -D nixos-fw -s 10.0.0.0/8 -p udp --dport 5353 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:83:      /run/current-system/sw/bin/iptables -D nixos-fw -s 172.16.0.0/12 -p udp --dport 5353 -j nixos-fw-accept || true
/etc/nixos/00-core/firewall.nix:84:      /run/current-system/sw/bin/iptables -D nixos-fw -s 192.168.0.0/16 -p udp --dport 5353 -j nixos-fw-accept || true
/etc/nixos/00-core/fail2ban.nix:19:      "127.0.0.1/8"
/etc/nixos/00-core/fail2ban.nix:21:      "10.0.0.0/8"
/etc/nixos/00-core/fail2ban.nix:22:      "172.16.0.0/12"
/etc/nixos/00-core/fail2ban.nix:23:      "192.168.0.0/16"
/etc/nixos/00-core/fail2ban.nix:24:      "100.64.0.0/10"

## URLs
/etc/nixos/20-services/media/arr-wire.nix:46:        SONARR_URL="''${SONARR_URL:-http://127.0.0.1:${toString config.my.ports.sonarr}}"
/etc/nixos/20-services/media/arr-wire.nix:47:        RADARR_URL="''${RADARR_URL:-http://127.0.0.1:${toString config.my.ports.radarr}}"
/etc/nixos/20-services/media/arr-wire.nix:48:        PROWLARR_URL="''${PROWLARR_URL:-http://127.0.0.1:${toString config.my.ports.prowlarr}}"
/etc/nixos/20-services/media/arr-wire.nix:49:        SABNZBD_URL="''${SABNZBD_URL:-http://127.0.0.1:${toString config.my.ports.sabnzbd}}"
/etc/nixos/20-services/media/_lib.nix:98:        { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/monica.nix:13:    appURL = "https://${host}";
/etc/nixos/20-services/apps/monica.nix:53:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/open-webui.nix:9:# Doku: https://mynixos.com/nixpkgs/option/services.open-webui.environment
/etc/nixos/20-services/apps/open-webui.nix:21:#   #     # OLLAMA_API_BASE_URL = "http://localhost:11434";
/etc/nixos/20-services/apps/open-webui.nix:27:#   https://github.com/NixOS/nixpkgs/issues/430433
/etc/nixos/20-services/apps/vaultwarden.nix:25:        url = "http://127.0.0.1:${toString config.my.ports.vaultwarden}";
/etc/nixos/20-services/apps/miniflux.nix:25:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/scrutiny.nix:22:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/paperless.nix:23:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/readeck.nix:34:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/audiobookshelf.nix:19:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/20-services/apps/n8n.nix:25:      url = "http://127.0.0.1:${toString config.my.ports.n8n}";
/etc/nixos/10-infrastructure/cloudflared-tunnel.nix:5:  traefikUrl = "https://127.0.0.1:${toString config.my.ports.traefikHttps}";
/etc/nixos/10-infrastructure/pocket-id.nix:12:      issuer = "https://nix-auth.${domain}";
/etc/nixos/10-infrastructure/pocket-id.nix:46:        url = "http://127.0.0.1:3000";
/etc/nixos/10-infrastructure/adguardhome.nix:22:          "https://one.one.one.one/dns-query"
/etc/nixos/10-infrastructure/adguardhome.nix:23:          "https://dns.quad9.net/dns-query"
/etc/nixos/10-infrastructure/ddns-updater.nix:27:      { url = "http://127.0.0.1:${toString port}"; }
/etc/nixos/10-infrastructure/homepage.nix:60:        url = "http://127.0.0.1:${toString homepagePort}";
/etc/nixos/10-infrastructure/traefik-core.nix:103:          address = "http://127.0.0.1:3000";
/etc/nixos/00-core/secrets.nix:79:      SONARR_URL=http://127.0.0.1:8989
/etc/nixos/00-core/secrets.nix:80:      RADARR_URL=http://127.0.0.1:7878
/etc/nixos/00-core/secrets.nix:81:      PROWLARR_URL=http://127.0.0.1:9696
/etc/nixos/00-core/secrets.nix:82:      SABNZBD_URL=http://127.0.0.1:8080

## Port Literals in Strings
/etc/nixos/20-services/apps/open-webui.nix:21:#   #     # OLLAMA_API_BASE_URL = "http://localhost:11434";
/etc/nixos/10-infrastructure/cloudflared-tunnel.nix:51:        # All nix-* hosts terminate at Traefik (HTTPS-only on localhost:443).
/etc/nixos/10-infrastructure/cloudflared-tunnel.nix:62:        default = "http_status:404";
/etc/nixos/10-infrastructure/pocket-id.nix:46:        url = "http://127.0.0.1:3000";
/etc/nixos/10-infrastructure/adguardhome.nix:14:        # Avoid conflict with systemd-resolved (127.0.0.53/54:53) while keeping
/etc/nixos/10-infrastructure/traefik-core.nix:25:    "2606:4700::/32"
/etc/nixos/10-infrastructure/traefik-core.nix:28:    "2405:8100::/32"
/etc/nixos/10-infrastructure/traefik-core.nix:29:    "2a06:98c0::/29"
/etc/nixos/10-infrastructure/traefik-core.nix:65:          resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
/etc/nixos/10-infrastructure/traefik-core.nix:71:          address = ":443";
/etc/nixos/10-infrastructure/traefik-core.nix:103:          address = "http://127.0.0.1:3000";
/etc/nixos/10-infrastructure/traefik-core.nix:131:          "fd7a:115c:a1e0::/48"
/etc/nixos/10-infrastructure/wireguard-vpn.nix:55:Endpoint = 91.148.237.21:51820
/etc/nixos/10-infrastructure/valkey.nix:4:  # sink:   local valkey on 127.0.0.1:6379 for internal apps
/etc/nixos/00-core/secrets.nix:79:      SONARR_URL=http://127.0.0.1:8989
/etc/nixos/00-core/secrets.nix:80:      RADARR_URL=http://127.0.0.1:7878
/etc/nixos/00-core/secrets.nix:81:      PROWLARR_URL=http://127.0.0.1:9696
/etc/nixos/00-core/secrets.nix:82:      SABNZBD_URL=http://127.0.0.1:8080

## Locale / TZ / NTP / DNS
/etc/nixos/10-infrastructure/adguardhome.nix:22:          "https://one.one.one.one/dns-query"
/etc/nixos/10-infrastructure/adguardhome.nix:23:          "https://dns.quad9.net/dns-query"
/etc/nixos/10-infrastructure/adguardhome.nix:25:        bootstrap_dns = [ "1.1.1.1" "9.9.9.9" ];
/etc/nixos/10-infrastructure/traefik-core.nix:65:          resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
/etc/nixos/00-core/locale.nix:11:      timeZone = "Europe/Berlin";
/etc/nixos/00-core/locale.nix:12:      locale = "de_DE.UTF-8";
/etc/nixos/00-core/locale.nix:14:      ntp = [ "0.de.pool.ntp.org" "1.de.pool.ntp.org" "2.de.pool.ntp.org" "3.de.pool.ntp.org" ];
/etc/nixos/00-core/locale.nix:17:      timeZone = "Europe/Vienna";
/etc/nixos/00-core/locale.nix:20:      ntp = [ "0.at.pool.ntp.org" "1.at.pool.ntp.org" "2.at.pool.ntp.org" "3.at.pool.ntp.org" ];
/etc/nixos/00-core/locale.nix:23:      timeZone = "Europe/Zurich";
/etc/nixos/00-core/locale.nix:26:      ntp = [ "0.ch.pool.ntp.org" "1.ch.pool.ntp.org" "2.ch.pool.ntp.org" "3.ch.pool.ntp.org" ];
/etc/nixos/00-core/locale.nix:32:      ntp = [ "0.uk.pool.ntp.org" "1.uk.pool.ntp.org" "2.uk.pool.ntp.org" "3.uk.pool.ntp.org" ];
/etc/nixos/00-core/locale.nix:57:    i18n.supportedLocales = lib.mkForce [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
/etc/nixos/00-core/locale.nix:65:      "1.1.1.1#one.one.one.one"
/etc/nixos/00-core/locale.nix:66:      "9.9.9.9#dns.quad9.net"
/etc/nixos/00-core/locale.nix:75:        "1.1.1.1#one.one.one.one"
/etc/nixos/00-core/locale.nix:76:        "1.0.0.1#one.one.one.one"
/etc/nixos/00-core/locale.nix:77:        "9.9.9.9#dns.quad9.net"
/etc/nixos/00-core/locale.nix:78:        "149.112.112.112#dns.quad9.net"

## User/Host Literals
/etc/nixos/scripts/preflight-switch.sh:29:for svc in sshd firewall fail2ban traefik; do
/etc/nixos/20-services/media-stack.nix:20:    "d /data/state/homepage 0755 homepage homepage -"
/etc/nixos/20-services/media/services-common.nix:4:  # sink:   host generation + traefik defaults for all media modules
/etc/nixos/20-services/media/_lib.nix:3:# sink:   generated per-service module: service config + tmpfiles + traefik router
/etc/nixos/20-services/media/_lib.nix:88:    services.traefik.dynamicConfigOptions.http = lib.mkIf cfg.expose.enable {
/etc/nixos/20-services/apps/monica.nix:9:  # sink: services.monica (phpfpm+nginx localhost) + services.traefik router/service
/etc/nixos/20-services/apps/monica.nix:44:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/20-services/apps/vaultwarden.nix:15:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/20-services/apps/miniflux.nix:7:  # sink:   services.miniflux + traefik router nix-miniflux.m7c5.de
/etc/nixos/20-services/apps/miniflux.nix:16:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/20-services/apps/scrutiny.nix:7:  # sink:   services.scrutiny + traefik router nix-scrutiny.m7c5.de
/etc/nixos/20-services/apps/scrutiny.nix:13:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/20-services/apps/paperless.nix:7:  # sink:   services.paperless + traefik router nix-paperless.m7c5.de
/etc/nixos/20-services/apps/paperless.nix:14:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/20-services/apps/readeck.nix:7:  # sink:   services.readeck + traefik router nix-readeck.m7c5.de
/etc/nixos/20-services/apps/readeck.nix:25:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/20-services/apps/audiobookshelf.nix:7:  # sink:   services.audiobookshelf + traefik router nix-audiobookshelf.m7c5.de
/etc/nixos/20-services/apps/audiobookshelf.nix:10:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/20-services/apps/n8n.nix:16:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/90-policy/security-assertions.nix:5:  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
/etc/nixos/90-policy/security-assertions.nix:11:  websecurePort = config.my.ports.traefikHttps;
/etc/nixos/90-policy/security-assertions.nix:18:    (must (config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CLOUDFLARE_DNS_API_TOKEN") "[SEC-SECRET-CF-001] cloudflare token variable name must be CLOUDFLARE_DNS_API_TOKEN")
/etc/nixos/90-policy/security-assertions.nix:48:    (must config.services.traefik.enable "security: Traefik must remain enabled")
/etc/nixos/90-policy/security-assertions.nix:49:    (must (!(config.services.traefik.staticConfigOptions.entryPoints ? web)) "security: Traefik HTTP entrypoint web must stay disabled")
/etc/nixos/90-policy/security-assertions.nix:50:    (must (config.services.traefik.staticConfigOptions.entryPoints.websecure.address == ":${toString websecurePort}") "security: Traefik websecure entrypoint must match my.ports.traefikHttps")
/etc/nixos/90-policy/security-assertions.nix:51:    (must (config.services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.provider == "cloudflare") "security: Traefik ACME DNS provider must stay cloudflare")
/etc/nixos/90-policy/security-assertions.nix:52:    (must (builtins.elem sharedSecretEnv traefikEnv) "security: Traefik must load secrets via my.secrets.files.sharedEnv")
/etc/nixos/90-policy/security-assertions.nix:56:    (must (lib.hasInfix "--host 127.0.0.1" (config.systemd.services.homepage.serviceConfig.ExecStart or "")) "security: Homepage service must bind to 127.0.0.1")
/etc/nixos/configuration.nix:25:    ./10-infrastructure/traefik-core.nix
/etc/nixos/configuration.nix:26:    # ./10-infrastructure/traefik-routes-public.nix
/etc/nixos/configuration.nix:27:    ./10-infrastructure/traefik-routes-internal.nix
/etc/nixos/configuration.nix:28:    ./10-infrastructure/homepage.nix
/etc/nixos/10-infrastructure/cloudflared-tunnel.nix:5:  traefikUrl = "https://127.0.0.1:${toString config.my.ports.traefikHttps}";
/etc/nixos/10-infrastructure/cloudflared-tunnel.nix:54:            service = traefikUrl;
/etc/nixos/10-infrastructure/pocket-id.nix:25:      #     email = "moritzbaumeister@gmail.com";
/etc/nixos/10-infrastructure/pocket-id.nix:34:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/10-infrastructure/ddns-updater.nix:18:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/10-infrastructure/homepage.nix:4:  homepageUser = "homepage";
/etc/nixos/10-infrastructure/homepage.nix:5:  homepageGroup = "homepage";
/etc/nixos/10-infrastructure/homepage.nix:6:  homepageConfigDir = "/data/state/homepage";
/etc/nixos/10-infrastructure/homepage.nix:7:  homepagePort = config.my.ports.homepage;
/etc/nixos/10-infrastructure/homepage.nix:10:  homepageLanguage = if localeProfile == "EN" then "en" else "de";
/etc/nixos/10-infrastructure/homepage.nix:11:  homepageSettings = pkgs.writeText "homepage-settings.yaml" "language: ${homepageLanguage}\n";
/etc/nixos/10-infrastructure/homepage.nix:15:  users.groups.${homepageGroup} = {};
/etc/nixos/10-infrastructure/homepage.nix:16:  users.users.${homepageUser} = {
/etc/nixos/10-infrastructure/homepage.nix:18:    group = homepageGroup;
/etc/nixos/10-infrastructure/homepage.nix:19:    home = homepageConfigDir;
/etc/nixos/10-infrastructure/homepage.nix:24:  systemd.services.homepage = {
/etc/nixos/10-infrastructure/homepage.nix:30:      User = homepageUser;
/etc/nixos/10-infrastructure/homepage.nix:31:      Group = homepageGroup;
/etc/nixos/10-infrastructure/homepage.nix:32:      WorkingDirectory = homepageConfigDir;
/etc/nixos/10-infrastructure/homepage.nix:33:      ExecStartPre = "${pkgs.coreutils}/bin/install -D -m 0644 -o ${homepageUser} -g ${homepageGroup} ${homepageSettings} ${homepageConfigDir}/settings.yaml";
/etc/nixos/10-infrastructure/homepage.nix:35:      # Manual refresh (optional): systemctl restart homepage
/etc/nixos/10-infrastructure/homepage.nix:39:        "HOMEPAGE_CONFIG=${homepageConfigDir}"
/etc/nixos/10-infrastructure/homepage.nix:46:    "d ${homepageConfigDir} 0755 ${homepageUser} ${homepageGroup} - -"
/etc/nixos/10-infrastructure/homepage.nix:50:  services.traefik.dynamicConfigOptions.http = {
/etc/nixos/10-infrastructure/homepage.nix:51:    routers.homepage = {
/etc/nixos/10-infrastructure/homepage.nix:56:      service = "homepage";
/etc/nixos/10-infrastructure/homepage.nix:58:    services.homepage = {
/etc/nixos/10-infrastructure/homepage.nix:60:        url = "http://127.0.0.1:${toString homepagePort}";
/etc/nixos/10-infrastructure/uptime-kuma.nix:4:  # sink:   uptime-kuma systemd service (traefik route handled separately if configured)
/etc/nixos/10-infrastructure/traefik.nix:4:    ./traefik-core.nix
/etc/nixos/10-infrastructure/traefik.nix:5:    ./traefik-routes-public.nix
/etc/nixos/10-infrastructure/traefik.nix:6:    ./traefik-routes-internal.nix
/etc/nixos/10-infrastructure/traefik-core.nix:34:  services.traefik = {
/etc/nixos/10-infrastructure/traefik-core.nix:36:    package = pkgs.traefik;
/etc/nixos/10-infrastructure/traefik-core.nix:37:    group = "traefik";
/etc/nixos/10-infrastructure/traefik-core.nix:38:    dataDir = "/var/lib/traefik";
/etc/nixos/10-infrastructure/traefik-core.nix:60:        email = "moritzbaumeister@gmail.com";
/etc/nixos/10-infrastructure/traefik-core.nix:61:        storage = "${config.services.traefik.dataDir}/acme.json";
/etc/nixos/10-infrastructure/traefik-core.nix:94:          moduleName = "github.com/traefik/plugin-simplecache";
/etc/nixos/10-infrastructure/traefik-core.nix:174:      http.routers.traefik-dashboard = {
/etc/nixos/10-infrastructure/traefik-core.nix:175:        rule = "Host(`traefik.${domain}`)";
/etc/nixos/10-infrastructure/traefik-core.nix:207:  systemd.services.traefik.serviceConfig.Environment =
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:8:    image = "traefik/whoami";
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:10:      "--label=traefik.enable=true"
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:11:      "--label=traefik.http.routers.whoami.rule=Host(`nix-whoami.${domain}`)"
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:12:      "--label=traefik.http.routers.whoami.entrypoints=websecure"
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:13:      "--label=traefik.http.routers.whoami.middlewares=internal-only-chain@file"
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:14:      "--label=traefik.http.routers.whoami.tls.certresolver=letsencrypt"
/etc/nixos/10-infrastructure/traefik-routes-internal.nix:15:      "--label=traefik.http.services.whoami.loadbalancer.server.port=80"
/etc/nixos/00-core/firewall.nix:26:    networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.traefikHttps ];
/etc/nixos/00-core/host.nix:12:      default = "moritz";
/etc/nixos/00-core/host.nix:17:      default = "nixhome";
/etc/nixos/00-core/ports.nix:19:    traefikHttps = 443;
/etc/nixos/00-core/ports.nix:23:    homepage = 8082;
/etc/nixos/00-core/server-rules.nix:13:  websecurePort = config.my.ports.traefikHttps;
/etc/nixos/00-core/server-rules.nix:21:  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
/etc/nixos/00-core/server-rules.nix:32:    (must (config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CLOUDFLARE_DNS_API_TOKEN") "[SEC-SECRET-CF-001] cloudflare token variable name must be CLOUDFLARE_DNS_API_TOKEN")
/etc/nixos/00-core/server-rules.nix:66:    (must config.services.traefik.enable "security: Traefik must remain enabled")
/etc/nixos/00-core/server-rules.nix:67:    (must (!(config.services.traefik.staticConfigOptions.entryPoints ? web)) "security: Traefik HTTP entrypoint web must stay disabled")
/etc/nixos/00-core/server-rules.nix:68:    (must (config.services.traefik.staticConfigOptions.entryPoints.websecure.address == ":${toString websecurePort}") "security: Traefik websecure entrypoint must match my.ports.traefikHttps")
/etc/nixos/00-core/server-rules.nix:69:    (must (config.services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.provider == "cloudflare") "security: Traefik ACME DNS provider must stay cloudflare")
/etc/nixos/00-core/server-rules.nix:70:    (must (builtins.elem sharedSecretEnv traefikEnv) "security: Traefik must load secrets via my.secrets.files.sharedEnv")
/etc/nixos/00-core/server-rules.nix:74:    (must (lib.hasInfix "--host 127.0.0.1" (config.systemd.services.homepage.serviceConfig.ExecStart or "")) "security: Homepage service must bind to 127.0.0.1")
/etc/nixos/00-core/configs-plan.nix:24:#   services.traefik.email
/etc/nixos/00-core/configs-plan.nix:25:#   services.traefik.domain
/etc/nixos/00-core/configs-plan.nix:26:#   services.homepage.domain
/etc/nixos/00-core/configs-plan.nix:32:#     current: /etc/nixos/10-infrastructure/traefik-core.nix
/etc/nixos/00-core/configs-plan.nix:34:#   - value: "moritzbaumeister@gmail.com"
/etc/nixos/00-core/configs-plan.nix:35:#     current: /etc/nixos/10-infrastructure/traefik-core.nix
/etc/nixos/00-core/secrets.nix:12:  # - my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName
/etc/nixos/00-core/secrets.nix:13:  #   -> systemd.services.traefik.serviceConfig.EnvironmentFile
/etc/nixos/00-core/secrets.nix:45:      traefikAcmeCloudflareDnsApiTokenVarName = lib.mkOption {
/etc/nixos/00-core/secrets.nix:87:        assertion = config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CLOUDFLARE_DNS_API_TOKEN";
/etc/nixos/00-core/secrets.nix:88:        message = "security: my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName must stay CLOUDFLARE_DNS_API_TOKEN (Traefik Cloudflare upstream requirement).";
