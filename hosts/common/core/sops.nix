# hosts/common/core/sops.nix
{ ... }:
{
  sops = {
    defaultSopsFile = ../../../secrets.sops.yaml;

    # Server-SSH-Host-Key wird zur Entschlüsselung genutzt
    # Kein separater Age-Key nötig – der Host-Key ist immer vorhanden
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Secrets werden hier eingetragen sobald sie gebraucht werden, z.B.:
    # secrets."cloudflare_api_token" = {
    #   owner = "traefik";
    # };
  };
}
