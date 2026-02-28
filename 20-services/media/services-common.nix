/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Media Global Options
 * TRACE-ID:     NIXH-SRV-017
 * PURPOSE:      Definition globaler Optionen für alle Media-Module (Host-Prefix, Cert-Resolver).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        20-services
 * STATUS:       Stable
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
