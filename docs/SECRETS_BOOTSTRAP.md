# Secrets/ENV Bootstrap (ohne sops)

Diese Repo-Variante bleibt bewusst bei Runtime-ENV-Dateien unter `/etc/secrets`.

## Schritt 1: echte Runtime-Datei anlegen (gehärtet)
```bash
sudo install -d -m 700 -o root -g root /etc/secrets
sudo install -m 600 -o root -g root /etc/secrets/homelab-runtime-secrets.env.example /etc/secrets/homelab-runtime-secrets.env
```

## Schritt 2: nur Werte eintragen
Nur rechts von `=` ausfüllen, Key-Namen nicht ändern.
Pflichtfelder:
- `CLOUDFLARE_DNS_API_TOKEN`
- `WG_PRIVADO_PRIVATE_KEY`

Optional:
- `SONARR_API_KEY`, `RADARR_API_KEY`, `PROWLARR_API_KEY`, `SABNZBD_API_KEY`

## Schritt 3: Rotation/Update sicher durchführen
```bash
sudoedit /etc/secrets/homelab-runtime-secrets.env
sudo chown root:root /etc/secrets/homelab-runtime-secrets.env
sudo chmod 600 /etc/secrets/homelab-runtime-secrets.env
```

## Schritt 4: Dienste neu laden und prüfen
```bash
sudo systemctl restart traefik
sudo systemctl start arr-wire.service
sudo journalctl -u traefik -n 100 --no-pager
sudo journalctl -u arr-wire -n 100 --no-pager
```

## Schritt 5: Preflight vor `switch`
```bash
sudo /etc/nixos/scripts/preflight-switch.sh
```
