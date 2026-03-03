{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-010";
    title = "OliveTin (SRE Exhausted)";
    description = "Web-based control panel with Wake-on-Access (Socket Activation) and secure command pinning.";
    layer = 20;
    nixpkgs.category = "web/apps";
    capabilities = [ "automation/shell" "system/control-panel" "security/socket-activation" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.olivetin;
  mtlsScript = "/etc/nixos/00-core/scripts/mtls-manager.sh";
  sopsScript = "/etc/nixos/00-core/scripts/add-sops-secret.sh";
in
{
  options.my.meta.olivetin = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for olivetin module";
  };


  config = lib.mkIf config.my.services.olivetin.enable {
    services.olivetin = {
      enable = true;
      path = with pkgs; [ bash openssl jq coreutils gnused systemd nixos-rebuild nix-output-monitor curl sops ];
      settings = {
        ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString port}";
        actions = [
          { title = "SOPS: Neues Secret"; shell = "sudo ${sopsScript} '{{ secret_key }}' '{{ secret_value }}'"; icon = "&#128272;"; arguments = [ { name = "secret_key"; type = "ascii"; } { name = "secret_value"; type = "ascii"; } ]; }
          { title = "System Update"; shell = "sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch 2>&1 | ${pkgs.nix-output-monitor}/bin/nom"; icon = "&#128259;"; }
        ];
      };
    };
    systemd.sockets.olivetin = { description = "OliveTin Socket"; wantedBy = [ "sockets.target" ]; listenStreams = [ (toString port) ]; };
    systemd.services.olivetin = { wantedBy = lib.mkForce []; requires = [ "olivetin.socket" ]; after = [ "olivetin.socket" ]; };
    security.sudo.extraRules = [ { users = [ "olivetin" ]; commands = [ { command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; } ]; } ];
  };
}
