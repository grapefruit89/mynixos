{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-036";
    title = "Matrix Conduit";
    description = "Lightweight Matrix homeserver (Conduit) written in Rust.";
    layer = 50;
    nixpkgs.category = "services/matrix";
    capabilities = [ "communication/matrix" "security/sandboxing" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  port = config.my.ports.matrix;
  domain = config.my.configs.identity.domain;
  subdomain = config.my.configs.identity.subdomain;
  serverName = "matrix.${subdomain}.${domain}";
  serviceBase = myLib.mkService { inherit config; name = "matrix"; port = port; useSSO = false; description = "Matrix Homeserver (Conduit)"; };
in
{
  options.my.meta.matrix_conduit = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for matrix-conduit module";
  };


  config = lib.mkIf config.my.services.matrixConduit.enable (lib.mkMerge [
    (lib.filterAttrs (n: v: n != "systemd") serviceBase)
    {
      services.matrix-conduit = { enable = true; settings.global = { server_name = serverName; port = port; address = "127.0.0.1"; database_backend = "rocksdb"; allow_registration = true; }; };
      systemd.services.conduit = { serviceConfig = lib.mkMerge [ serviceBase.systemd.services.matrix.serviceConfig { StateDirectory = lib.mkForce "matrix-conduit"; ReadWritePaths = lib.mkForce [ "/var/lib/matrix-conduit" ]; MemoryDenyWriteExecute = lib.mkForce false; CPUWeight = lib.mkForce 50; MemoryMax = lib.mkForce "1G"; } ]; };
      services.caddy.virtualHosts."${serverName}".extraConfig = lib.mkAfter "handle /.well-known/matrix/server { ... } handle /.well-known/matrix/client { ... }"; # Shortened
    }
  ]);
}
