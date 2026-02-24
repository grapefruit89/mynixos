{ ... }:
{
  # Natives NixOS WireGuard (wg-quick), ohne vpn-confinement.
  # Aktivierung erfolgt erst, wenn dieses Modul in configuration.nix importiert wird.
  networking.wg-quick.interfaces.privado = {
    autostart = false;

    # Lege die Datei ausserhalb von Git ab, z.B.:
    # /etc/secrets/wireguard/privado.conf
    # Inhalt ist ein normales wg-quick Interface-Config.
    configFile = "/etc/secrets/wireguard/privado.conf";
  };
}
