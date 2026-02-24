{ lib }:
# source: name/port/stateOption parameters + my.media.defaults
# sink:   generated per-service module: service config + tmpfiles + traefik router
{ name
, port
, stateOption
, defaultStateDir
, supportsUserGroup ? true
, defaultUser ? name
, defaultGroup ? name
, statePathSuffix ? null
}:
{ config, ... }:
let
  cfg = config.my.media.${name};
  common = config.my.media.defaults;
  stateValue =
    if statePathSuffix == null
    then cfg.stateDir
    else "${cfg.stateDir}/${statePathSuffix}";
  defaultHost =
    if common.domain == null
    then null
    else "${common.hostPrefix}-${name}.${common.domain}";
in
{
  options.my.media.${name} = {
    enable = lib.mkEnableOption "the ${name} service";

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = defaultStateDir;
      description = "State directory for ${name}.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "System user for ${name}.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultGroup;
      description = "System group for ${name}.";
    };

    expose = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Expose ${name} behind Traefik.";
      };

      host = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = defaultHost;
        description = "FQDN used for the Traefik router.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.stateDir;
        message = "my.media.${name}.stateDir must be an absolute path.";
      }
      {
        assertion = (!cfg.expose.enable) || (cfg.expose.host != null);
        message = "my.media.${name}: expose.host is required when expose.enable = true.";
      }
    ];

    services.${name} = {
      enable = true;
      openFirewall = lib.mkForce false;
      ${stateOption} = stateValue;
    } // lib.optionalAttrs supportsUserGroup {
      user = cfg.user;
      group = cfg.group;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    services.traefik.dynamicConfigOptions.http = lib.mkIf cfg.expose.enable {
      routers.${name} = {
        rule = "Host(`${cfg.expose.host}`)";
        entryPoints = [ "websecure" ];
        tls.certResolver = common.certResolver;
        middlewares = [ common.secureMiddleware ];
        service = name;
      };

      services.${name}.loadBalancer.servers = [
        { url = "http://127.0.0.1:${toString port}"; }
      ];
    };
  };
}
