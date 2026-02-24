{ ... }:
{
  # Natives NixOS WireGuard (wg-quick), ohne vpn-confinement.
  networking.wg-quick.interfaces.privado = {
    autostart = true;
    configFile = "/etc/secrets/wireguard/privado.conf";
  };
}
