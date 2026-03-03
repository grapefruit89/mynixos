{ ... }:
{
  imports = [
    ./service-app-couchdb.nix
    ./service-app-filebrowser.nix
    ./service-app-karakeep.nix
    ./service-app-matrix-conduit.nix
    ./service-app-monica.nix
    ./service-app-vaultwarden.nix
    # ./SERVICE_TEMPLATE.nix # TEMPLATE ONLY
  ];
}
