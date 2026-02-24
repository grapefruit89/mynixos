{ lib, config, ... }:
{
  # Secret contract (single source of truth)
  # source: my.secrets.files.sharedEnv
  # sinks:
  # - my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName
  #   -> systemd.services.traefik.serviceConfig.EnvironmentFile
  #   -> Traefik ACME dnsChallenge provider=cloudflare
  # - my.secrets.vars.wgPrivadoPrivateKeyVarName
  #   -> activation script wgPrivadoConfigFromEnv
  #   -> my.secrets.files.wireguardPrivadoConf
  #   -> networking.wg-quick.interfaces.privado.configFile
  # - my.secrets.files.cloudflaredTunnelCredentials
  #   -> services.cloudflared.tunnels.<id>.credentialsFile
  options.my.secrets = {
    files = {
      sharedEnv = lib.mkOption {
        type = lib.types.str;
        default = "/etc/secrets/homelab-runtime-secrets.env";
        description = "Central runtime secrets env file (isomorphic names + source->sink comments).";
      };

      wireguardPrivadoConf = lib.mkOption {
        type = lib.types.str;
        default = "/etc/secrets/wireguard/privado.conf";
        description = "Generated wg-quick config file for the 'privado' interface.";
      };

      cloudflaredTunnelCredentials = lib.mkOption {
        type = lib.types.str;
        default = "/etc/secrets/cloudflared/m7c5-tunnel.json";
        description = "Cloudflare Tunnel credentials JSON (tunnel UUID json).";
      };
    };

    vars = {
      # NOTE: value must stay CF_DNS_API_TOKEN because Traefik's Cloudflare provider
      # reads exactly this upstream env var.
      traefikAcmeCloudflareDnsApiTokenVarName = lib.mkOption {
        type = lib.types.str;
        default = "CF_DNS_API_TOKEN";
        description = "Upstream-required env var name for Traefik ACME Cloudflare DNS challenge.";
      };

      # NOTE: value must stay WG_PRIVADO_PRIVATE_KEY because wireguard-vpn.nix
      # activation script consumes this exact variable by contract.
      wgPrivadoPrivateKeyVarName = lib.mkOption {
        type = lib.types.str;
        default = "WG_PRIVADO_PRIVATE_KEY";
        description = "Env var name used to generate wg-quick privado config.";
      };
    };
  };

  config.assertions = [
    {
      assertion = config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CF_DNS_API_TOKEN";
      message = "security: my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName must stay CF_DNS_API_TOKEN (Traefik Cloudflare upstream requirement).";
    }
    {
      assertion = config.my.secrets.vars.wgPrivadoPrivateKeyVarName == "WG_PRIVADO_PRIVATE_KEY";
      message = "security: my.secrets.vars.wgPrivadoPrivateKeyVarName must stay WG_PRIVADO_PRIVATE_KEY.";
    }
  ];
}
