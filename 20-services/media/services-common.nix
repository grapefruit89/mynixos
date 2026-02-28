/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-031
 *   title: "Services Common"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:d7aff29c2809cfad43133a19ad98bb4e31d101fba5fe3d01dd57d3d6d480ee81
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
