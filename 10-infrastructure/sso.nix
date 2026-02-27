# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: SSO via Pocket-ID + Traefik ForwardAuth (OIDC-basiert)
#   priority: P2 (High)
#   benefit: Single Sign-On für alle internen Services

{ config, lib, pkgs, ... }:

let
  cfg = config.my.profiles.services.pocket-id;
  domain = config.my.configs.identity.domain;
  pocketIdPort = config.my.ports.pocketId;
  
  protectedServices = {
    sonarr = "nix-sonarr";
    radarr = "nix-radarr";
    prowlarr = "nix-prowlarr";
    readarr = "nix-readarr";
    traefik = "traefik";
    netdata = "netdata";
    scrutiny = "scrutiny";
  };
  
  allowedUrls = lib.mapAttrsToList
    (name: subdomain: "https://${subdomain}.${domain}")
    protectedServices;
    
  allowedRedirectUrls = lib.concatStringsSep "," (allowedUrls ++ [
    "https://auth.${domain}/callback"
  ]);
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id.settings = {
      # Nutze Komma-separierten String für die Liste
      ALLOWED_REDIRECT_URLS = allowedRedirectUrls;
      SESSION_TTL_SECONDS = "86400";
      REFRESH_TOKEN_TTL_SECONDS = "2592000";
    };
    
    services.traefik.dynamicConfigOptions.http.middlewares = {
      sso-auth = {
        forwardAuth = {
          address = "http://127.0.0.1:${toString pocketIdPort}/api/auth/verify";
          authResponseHeaders = [
            "X-Auth-User"
            "X-Auth-Email"
            "X-Auth-Name"
          ];
          trustForwardHeader = true;
          authRequestHeaders = [
            "Cookie"
            "X-Forwarded-Proto"
            "X-Forwarded-Host"
          ];
        };
      };
      
      sso-chain = {
        chain.middlewares = [
          "sso-auth@file"
          "secure-headers@file"
        ];
      };
      
      sso-internal = {
        chain.middlewares = [
          "local-ip-whitelist@file"
          "sso-auth@file"
          "secure-headers@file"
        ];
      };
    };
    
    services.traefik.dynamicConfigOptions.http.routers = {
      sonarr.middlewares = lib.mkForce [ "sso-chain@file" ];
      radarr.middlewares = lib.mkForce [ "sso-chain@file" ];
      prowlarr.middlewares = lib.mkForce [ "sso-chain@file" ];
      readarr.middlewares = lib.mkForce [ "sso-chain@file" ];
      traefik-dashboard.middlewares = lib.mkForce [ "sso-internal@file" ];
      scrutiny.middlewares = lib.mkForce [ "sso-chain@file" ];
      
      netdata = {
        rule = "Host(`netdata.${domain}`)";
        entryPoints = [ "websecure" ];
        tls.certResolver = "letsencrypt";
        middlewares = [ "sso-internal@file" ];
        service = "netdata";
      };
    };
    
    services.traefik.dynamicConfigOptions.http.services.netdata.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.my.ports.netdata}";
    }];

    systemd.services.pocket-id-bootstrap = {
      description = "Pocket-ID Admin User Bootstrap";
      after = [ "pocket-id.service" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "!/var/lib/pocket-id/.bootstrapped";
      serviceConfig.Type = "oneshot";
      script = ''
        for i in {1..30}; do
          if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:${toString pocketIdPort}/health >/dev/null 2>&1; then
            touch /var/lib/pocket-id/.bootstrapped
            break
          fi
          sleep 2
        done
      '';
    };
  };
}
