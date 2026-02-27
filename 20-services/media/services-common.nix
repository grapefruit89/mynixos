{ lib, config, ... }:
{
  # source: my.media.defaults.* options
  # sink:   host generation + traefik defaults for all media modules
  options.my.media.defaults = {
    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "example.com";
      description = "Base domain used to derive default service hosts.";
    };

    hostPrefix = lib.mkOption {
      type = lib.types.str;
      default = "nix";
      description = "Prefix used for generated hosts, e.g. nix-sonarr.example.com.";
    };

    certResolver = lib.mkOption {
      type = lib.types.str;
      default = "letsencrypt";
      description = "Traefik certificate resolver name.";
    };

    secureMiddleware = lib.mkOption {
      type = lib.types.str;
      default = "secure-headers@file";
      description = "Traefik middleware for security headers.";
    };

    netns = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Network Namespace to run media services in (VPN Confinement).";
    };
  };

  config.assertions = [
    {
      assertion = config.my.media.defaults.domain != null;
      # source-id: CFG.identity.domain
      message = "my.media.defaults.domain must be set for generated media hostnames.";
    }
  ];
}
