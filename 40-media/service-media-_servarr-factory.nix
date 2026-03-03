{ lib, pkgs }:
let
  servarrHardening = { CapabilityBoundingSet = ""; NoNewPrivileges = true; ProtectHome = true; ProtectClock = true; ProtectKernelLogs = true; PrivateTmp = true; PrivateDevices = true; PrivateUsers = true; ProtectKernelTunables = true; ProtectKernelModules = true; ProtectControlGroups = true; RestrictSUIDSGID = true; RemoveIPC = true; UMask = "0022"; ProtectHostname = true; ProtectProc = "invisible"; ProcSubset = "pid"; RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ]; RestrictNamespaces = true; RestrictRealtime = true; LockPersonality = true; SystemCallArchitectures = "native"; SystemCallFilter = [ "@system-service" "~@privileged" "~@debug" "~@mount" "@chown" ]; };
in
{
  mkServarrSettingsOptions = name: port: lib.mkOption { type = lib.types.submodule { freeformType = (pkgs.formats.ini { }).type; options = { update = { mechanism = lib.mkOption { type = with lib.types; nullOr (enum [ "external" "builtIn" "script" ]); default = "external"; }; automatically = lib.mkOption { type = lib.types.bool; default = false; }; }; server = { port = lib.mkOption { type = lib.types.port; default = port; }; bindAddress = lib.mkOption { type = lib.types.str; default = "127.0.0.1"; }; }; log = { analyticsEnabled = lib.mkOption { type = lib.types.bool; default = false; }; }; }; }; default = { }; };
  mkServarrEnvironmentFiles = name: lib.mkOption { type = lib.types.listOf lib.types.path; default = [ ]; };
  mkServarrSettingsEnvVars = name: settings: lib.pipe settings [ (lib.mapAttrsRecursive (path: value: lib.optionalAttrs (value != null) { name = lib.toUpper "${name}__${lib.concatStringsSep "__" path}"; value = toString (if lib.isBool value then lib.boolToString value else value); })) (lib.collect (x: lib.isString x.name or false && lib.isString x.value or false)) lib.listToAttrs ];
  mkServarrHardening = servarrHardening;
  mkServarrTmpfiles = name: cfg: { "10-${name}".${cfg.stateDir}.d = { inherit (cfg) user group; mode = "0700"; }; };
  mkServarrUserGroup = name: cfg: defaultGroup: { users.users.${cfg.user} = lib.mkIf (cfg.user == name) { group = cfg.group; home = cfg.stateDir; isSystemUser = true; description = "${name} service user"; }; users.groups.${cfg.group} = lib.mkDefault { }; };
}
