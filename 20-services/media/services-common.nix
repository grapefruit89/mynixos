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
 *   checksum: sha256:9b337206092cb6ad8b2275963ca06eb6c234c4e3c14c392e069f594f67af476b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
