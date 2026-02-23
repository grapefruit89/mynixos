{ config, inputs, ... }:
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  vpnNamespaces.privado = {
    enable = true;
    wireguardConfig = {
      # WICHTIG: Ersetze dies manuell mit dem Pfad zu deinem WireGuard Private Key auf dem Server.
      # Beispiel: privateKeyFile = "/etc/wireguard/privado_wg_key";
      # Der Schlüssel muss außerhalb des Git-Repos liegen und korrekte Berechtigungen haben (chmod 600).
      # privateKeyFile = "/var/lib/secrets/privado_wg_key"; # <- Alte Referenz, falls du es später wieder nutzen möchtest
      address = [ "100.64.3.40/32" ];
      dns = [ "198.18.0.1" "198.18.0.2" ];
    };
    portMappings = [
      { from = 8080; to = 8080; } # Example: For SABnzbd
    ];
    peers = [{
      publicKey = "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
      allowedIPs = [ "0.0.0.0/0" ];
      endpoint = "91.148.237.21:51820";
    }];
  };
}
