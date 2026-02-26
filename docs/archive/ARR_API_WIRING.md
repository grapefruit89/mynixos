# ARR API-Verdrahtung: manuell vs. automatisiert

## Was bedeutet „automatisch verdrahtet"?
Gemeint ist das automatische Setzen der API-Keys zwischen Prowlarr, Sonarr, Radarr und SABnzbd.

Typische Kanten:
- Prowlarr -> Sonarr/Radarr
- SABnzbd -> Sonarr/Radarr
- Sonarr/Radarr -> Prowlarr

## Aufwand manuell
Einmalig ca. 10–15 Minuten in den UIs. Danach persistent in den jeweiligen Datenbanken.

## Jetzt im Repo umgesetzt
Es gibt einen systemd-Helper `arr-wire.service` (oneshot), der die wichtigsten API-Keys aus
`/etc/secrets/homelab-runtime-secrets.env` liest und API-Erreichbarkeit validiert.

### Manuell starten (z. B. nach Key-Rotation)
- `sudo systemctl start arr-wire.service`
- `sudo journalctl -u arr-wire -n 100 --no-pager`

### Optional bei jedem Boot laufen lassen
In deiner Host-Konfiguration:
```nix
my.media.arrWire = {
  enable = true;
  runOnBoot = true;
};
```

## Hinweis
Der Service ist bewusst „safe by default" (Validierung/Health), damit Rotationen reproduzierbar sind,
ohne unbeabsichtigt Konfigurationen per API zu überschreiben.
