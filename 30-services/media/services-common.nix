/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Services Common
 * TRACE-ID:     NIXH-SRV-022
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:9c26651882bff4ad313ce5b5e896bbe0a9bcf0bbbf90aedfb2c6843e9e050256
 */

{ lib, config, ... }:
{
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
      description = "Prefix used for generated hosts.";
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
      description = "Network Namespace to run media services in.";
    };
  };

  config.assertions = [
    {
      assertion = config.my.media.defaults.domain != null;
      message = "my.media.defaults.domain must be set for generated media hostnames.";
    }
  ];
}
